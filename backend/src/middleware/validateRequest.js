import { AppError } from '../utils/AppError.js';

export const validateRequest = (schema) => {
  return (req, _res, next) => {
    const target = {
      body: req.body,
      params: req.params,
      query: req.query,
    };

    const result = schema.safeParse(target);

    if (!result.success) {
      const details = result.error.issues.map((issue) => ({
        path: issue.path.join('.'),
        message: issue.message,
      }));

      const message = details[0]?.message || 'Invalid request payload';
      const error = new AppError(message, 400);
      error.details = details;
      return next(error);
    }

    req.body = result.data.body;
    req.params = result.data.params;
    req.query = result.data.query;
    return next();
  };
};
