import {
  PlanLimitError,
  enforcePlanLimitsAtSignup,
  enforcePlanLimitsForUser,
} from '../services/plan-limit.service.js';

function sendPlanLimitError(res, error) {
  return res.status(error.statusCode).json({
    error: error.message,
    code: error.code,
    details: error.details,
  });
}

/**
 * Authenticated middleware factory for plan-limit checks.
 *
 * Typical usage:
 * - Adding Halo profiles
 * - Adding guardians
 * - Upgrading/downgrading plan for the authenticated account
 *
 * @param {object} deps
 * @param {import('@prisma/client').PrismaClient} deps.prisma
 * @param {(req: import('express').Request) => Promise<string>} deps.resolvePlanId
 * @param {(req: import('express').Request) => number} [deps.resolveAdditionalHalos]
 * @param {(req: import('express').Request) => number} [deps.resolveAdditionalGuardians]
 * @param {(args: { prisma: any, userId: string }) => Promise<number>} [deps.resolveCurrentHaloCount]
 * @param {(args: { prisma: any, userId: string }) => Promise<number>} [deps.resolveCurrentGuardianCount]
 */
export function createPlanLimitMiddleware({
  prisma,
  resolvePlanId,
  resolveAdditionalHalos = () => 0,
  resolveAdditionalGuardians = () => 0,
  resolveCurrentHaloCount,
  resolveCurrentGuardianCount,
}) {
  return async function planLimitMiddleware(req, res, next) {
    try {
      const userId = req.user?.id;
      if (!userId) {
        return res.status(401).json({ error: 'Unauthorized' });
      }

      const planId = await resolvePlanId(req);
      const additionalHalos = resolveAdditionalHalos(req);
      const additionalGuardians = resolveAdditionalGuardians(req);

      await enforcePlanLimitsForUser({
        prisma,
        userId,
        planId,
        additionalHalos,
        additionalGuardians,
        resolveCurrentHaloCount,
        resolveCurrentGuardianCount,
      });

      return next();
    } catch (error) {
      if (error instanceof PlanLimitError) {
        return sendPlanLimitError(res, error);
      }

      return next(error);
    }
  };
}

/**
 * Signup middleware factory for enforcing plan limits before account/profile creation.
 *
 * @param {object} deps
 * @param {import('@prisma/client').PrismaClient} deps.prisma
 * @param {(req: import('express').Request) => Promise<string>} deps.resolvePlanId
 * @param {(req: import('express').Request) => number} [deps.resolveRequestedHalos]
 * @param {(req: import('express').Request) => number} [deps.resolveRequestedGuardians]
 */
export function createSignupPlanLimitMiddleware({
  prisma,
  resolvePlanId,
  resolveRequestedHalos = () => 1,
  resolveRequestedGuardians = () => 0,
}) {
  return async function signupPlanLimitMiddleware(req, res, next) {
    try {
      const planId = await resolvePlanId(req);
      const requestedHalos = resolveRequestedHalos(req);
      const requestedGuardians = resolveRequestedGuardians(req);

      const plan = await prisma.subscriptionPlan.findUnique({ where: { id: planId } });
      if (!plan) {
        return res.status(404).json({ error: 'Subscription plan not found.' });
      }

      enforcePlanLimitsAtSignup({
        plan,
        requestedHalos,
        requestedGuardians,
      });

      return next();
    } catch (error) {
      if (error instanceof PlanLimitError) {
        return sendPlanLimitError(res, error);
      }

      return next(error);
    }
  };
}
