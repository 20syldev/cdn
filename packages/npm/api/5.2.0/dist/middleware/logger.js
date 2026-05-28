import { createLogger } from '@20syldev/logger.ts';
import { MAX_LOG_ENTRIES } from '../constants.js';
export const logger = createLogger({
    maxEntries: MAX_LOG_ENTRIES,
    console: true,
    theme: 'colored',
});
export function loggerMiddleware(req, res, next) {
    if (req.method === 'HEAD') {
        next();
        return;
    }
    if (req.originalUrl === '/logs') {
        next();
        return;
    }
    const startTime = Date.now();
    const platform = req.headers['sec-ch-ua-platform']?.replace(/"/g, '');
    res.on('finish', () => {
        const status = res.statusCode === 304 ? 200 : res.statusCode;
        const duration = `${Date.now() - startTime}ms`;
        logger.log({ method: req.method, url: req.originalUrl, status, duration, platform });
    });
    next();
}
//# sourceMappingURL=logger.js.map