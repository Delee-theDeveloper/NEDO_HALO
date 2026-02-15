/**
 * Plan limit enforcement for Halo and Guardian counts.
 *
 * Intended usage:
 * - Signup: validate requested initial usage before creating records
 * - Upgrade/downgrade: validate current usage against selected plan
 * - Ongoing CRUD: validate projected usage before mutating resources
 */

const PLAN_LIMIT_EXCEEDED_CODE = 'PLAN_LIMIT_EXCEEDED';

export class PlanLimitError extends Error {
  constructor(message, details = {}) {
    super(message);
    this.name = 'PlanLimitError';
    this.statusCode = 409;
    this.code = PLAN_LIMIT_EXCEEDED_CODE;
    this.details = details;
  }
}

function toNonNegativeInteger(value, fieldName) {
  if (!Number.isInteger(value) || value < 0) {
    throw new TypeError(`${fieldName} must be a non-negative integer.`);
  }
  return value;
}

function toPlanLimit(value, fieldName) {
  if (value === null || value === undefined) {
    return Number.POSITIVE_INFINITY;
  }

  if (!Number.isInteger(value) || value < 0) {
    throw new TypeError(`${fieldName} must be a non-negative integer or null.`);
  }

  return value;
}

function assertResourceLimit({
  planName,
  resource,
  maxAllowed,
  currentCount,
  additionalCount = 0,
  message,
}) {
  const normalizedCurrent = toNonNegativeInteger(currentCount, `${resource}.currentCount`);
  const normalizedAdditional = toNonNegativeInteger(
    additionalCount,
    `${resource}.additionalCount`,
  );
  const normalizedMax = toPlanLimit(maxAllowed, `${resource}.maxAllowed`);
  const projected = normalizedCurrent + normalizedAdditional;

  if (projected > normalizedMax) {
    throw new PlanLimitError(message, {
      planName,
      resource,
      maxAllowed: normalizedMax,
      current: normalizedCurrent,
      requestedAdditional: normalizedAdditional,
      projected,
    });
  }
}

/**
 * Throws when projected Halo usage exceeds plan max.
 */
export function assertHaloLimit({
  planName,
  maxHalos,
  currentHaloCount,
  additionalHalos = 0,
}) {
  assertResourceLimit({
    planName,
    resource: 'halos',
    maxAllowed: maxHalos,
    currentCount: currentHaloCount,
    additionalCount: additionalHalos,
    message: 'Halo limit exceeded for selected subscription plan.',
  });
}

/**
 * Throws when projected Guardian usage exceeds plan max.
 */
export function assertGuardianLimit({
  planName,
  maxGuardians,
  currentGuardianCount,
  additionalGuardians = 0,
}) {
  assertResourceLimit({
    planName,
    resource: 'guardians',
    maxAllowed: maxGuardians,
    currentCount: currentGuardianCount,
    additionalCount: additionalGuardians,
    message: 'Guardian limit exceeded for selected subscription plan.',
  });
}

/**
 * Validates whether projected usage fits inside a target plan.
 */
export function enforcePlanLimits({
  plan,
  currentHaloCount,
  currentGuardianCount,
  additionalHalos = 0,
  additionalGuardians = 0,
}) {
  if (!plan) {
    throw new Error('Plan is required for limit enforcement.');
  }

  assertHaloLimit({
    planName: plan.name,
    maxHalos: plan.maxHalos,
    currentHaloCount,
    additionalHalos,
  });

  assertGuardianLimit({
    planName: plan.name,
    maxGuardians: plan.maxGuardians,
    currentGuardianCount,
    additionalGuardians,
  });
}

/**
 * Signup-time check (new account/profile setup).
 */
export function enforcePlanLimitsAtSignup({
  plan,
  requestedHalos = 1,
  requestedGuardians = 0,
}) {
  enforcePlanLimits({
    plan,
    currentHaloCount: 0,
    currentGuardianCount: 0,
    additionalHalos: requestedHalos,
    additionalGuardians: requestedGuardians,
  });
}

/**
 * Upgrade/downgrade check against current usage.
 */
export function enforcePlanLimitsForPlanChange({
  plan,
  currentHaloCount,
  currentGuardianCount,
}) {
  enforcePlanLimits({
    plan,
    currentHaloCount,
    currentGuardianCount,
    additionalHalos: 0,
    additionalGuardians: 0,
  });
}

/**
 * Loads usage + plan from DB, then enforces limits.
 *
 * Override the count resolvers if your schema uses different relations/fields.
 */
export async function enforcePlanLimitsForUser({
  prisma,
  userId,
  planId,
  additionalHalos = 0,
  additionalGuardians = 0,
  resolveCurrentHaloCount = ({ prisma: db, userId: uid }) =>
    db.haloProfile.count({ where: { ownerId: uid } }),
  resolveCurrentGuardianCount = ({ prisma: db, userId: uid }) =>
    db.guardian.count({ where: { halo: { ownerId: uid } } }),
}) {
  if (!prisma) {
    throw new Error('Prisma client is required.');
  }
  if (!userId) {
    throw new Error('userId is required.');
  }
  if (!planId) {
    throw new Error('planId is required.');
  }

  const plan = await prisma.subscriptionPlan.findUnique({ where: { id: planId } });
  if (!plan) {
    throw new Error('Subscription plan not found.');
  }

  let currentHaloCount;
  let currentGuardianCount;

  try {
    [currentHaloCount, currentGuardianCount] = await Promise.all([
      resolveCurrentHaloCount({ prisma, userId }),
      resolveCurrentGuardianCount({ prisma, userId }),
    ]);
  } catch (error) {
    throw new Error(
      `Failed to resolve current usage counts. Provide custom resolvers if your schema differs. ${error.message}`,
    );
  }

  enforcePlanLimits({
    plan,
    currentHaloCount,
    currentGuardianCount,
    additionalHalos,
    additionalGuardians,
  });

  return {
    plan,
    currentHaloCount,
    currentGuardianCount,
    projectedHaloCount: currentHaloCount + additionalHalos,
    projectedGuardianCount: currentGuardianCount + additionalGuardians,
  };
}
