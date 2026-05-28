import { Router } from 'express';
import { env } from '../config/env.js';
import { versions } from '../config/versions.js';
import { DOCS_URL, GITHUB_CACHE_TTL } from '../constants.js';
import { chatStorage, ipLimits } from '../storage/index.js';
import { since } from '../utils/helpers.js';
import { error } from '../utils/response.js';
const router = Router();
let activity = [];
let lastFetch = 0;
// Display version information
router.get('/:version', (req, res) => {
    const version = req.params.version;
    const versionConfig = versions[version];
    const endpoints = Object.keys(versionConfig.endpoints).reduce((acc, method) => {
        const endpointList = versionConfig.endpoints[method];
        if (!endpointList)
            return acc;
        acc[method] = endpointList
            .filter(({ name }) => name !== 'website')
            .sort((a, b) => a.name.localeCompare(b.name))
            .reduce((group, endpoint) => {
            if (endpoint.children) {
                group[endpoint.name] = Object.keys(endpoint.children)
                    .sort((a, b) => a.localeCompare(b))
                    .reduce((childGroup, childName) => {
                    childGroup[childName] = `/${version}${endpoint.children[childName]}`;
                    return childGroup;
                }, {});
            }
            else {
                group[endpoint.name] = `/${version}${endpoint.path}`;
            }
            return group;
        }, {});
        return acc;
    }, {});
    res.jsonResponse({
        version,
        documentation: `${DOCS_URL}/${version}`,
        endpoints,
    });
});
// Generate a fictional postal address
router.get('/:version/address', (req, res) => {
    const { country, count } = req.query;
    const { version } = req.params;
    const addressFn = req.module.address;
    if (!addressFn) {
        error(res, 404, `Endpoint not available in ${version}.`, `${req.latest}/address`);
        return;
    }
    const parsedCount = count !== undefined ? parseInt(count, 10) : 1;
    try {
        const result = addressFn(country, parsedCount);
        res.jsonResponse(result);
    }
    catch (err) {
        error(res, 400, err.message, `${req.version}/address`);
    }
});
// Parse a User-Agent string
router.get('/:version/agent', (req, res) => {
    const ua = req.query.ua ?? req.headers['user-agent'] ?? '';
    try {
        const agentFn = req.module.agent;
        const result = agentFn(ua);
        res.jsonResponse(result);
    }
    catch (err) {
        error(res, 400, err.message, `${req.version}/agent`);
    }
});
// Algorithms
router.get('/:version/algorithms', (req, res) => {
    const { method, value, value2 } = req.query;
    const { version } = req.params;
    const algorithms = req.module.algorithms;
    if (!algorithms || !method || !Object.hasOwn(algorithms, method)) {
        error(res, 400, 'Please provide a valid algorithm (?method={algorithm})', `${version}/algorithms`);
        return;
    }
    try {
        const answer = algorithms[method](value, value2);
        res.jsonResponse({ answer });
    }
    catch (err) {
        error(res, 400, err.message, `${req.version}/algorithms`);
    }
});
// Generate an identicon or pixel-art avatar from a seed
router.get('/:version/avatar', (req, res) => {
    const avatarFn = req.module.avatar;
    if (!avatarFn) {
        error(res, 404, `Endpoint not available in ${req.version}.`, `${req.latest}/avatar`);
        return;
    }
    const { seed, size, type, bg, format } = req.query;
    try {
        const { contentType, body } = avatarFn({
            seed: seed,
            size: size !== undefined ? parseInt(size, 10) : undefined,
            type: type,
            bg: bg,
            format: format,
        });
        res.type(contentType).send(body);
    }
    catch (err) {
        error(res, 400, err.message, `${req.version}/avatar`);
    }
});
// Generate a barcode image
router.get('/:version/barcode', (req, res) => {
    const barcodeFn = req.module.barcode;
    if (!barcodeFn) {
        error(res, 404, `Endpoint not available in ${req.version}.`, `${req.latest}/barcode`);
        return;
    }
    const { data, type, width, height, format, color, bg } = req.query;
    if (!data) {
        error(res, 400, 'Please provide data to encode (?data={string})', `${req.version}/barcode`);
        return;
    }
    try {
        const { contentType, body } = barcodeFn({
            data: data,
            type: type,
            width: width !== undefined ? parseInt(width, 10) : undefined,
            height: height !== undefined ? parseInt(height, 10) : undefined,
            format: format,
            color: color,
            bg: bg,
        });
        res.type(contentType).send(body);
    }
    catch (err) {
        error(res, 400, err.message, `${req.version}/barcode`);
    }
});
// Generate captcha
router.get('/:version/captcha', (req, res) => {
    try {
        if (since(req.version, 4)) {
            const captchaFn = req.module.captcha;
            const result = captchaFn({
                text: req.query.text,
                length: req.query.length ? Number(req.query.length) : undefined,
                width: req.query.width ? Number(req.query.width) : undefined,
                height: req.query.height ? Number(req.query.height) : undefined,
                noise: req.query.noise,
                bg: req.query.bg,
                color: req.query.color,
            });
            res.set('X-Captcha-Text', result.text);
            res.type('png').send(result.body);
        }
        else {
            const text = req.query.text;
            if (!text) {
                error(res, 400, 'Please provide a valid argument (?text={text})', `${req.version}/captcha`);
                return;
            }
            const result = req.module.captcha(text);
            res.type('png').send(result);
        }
    }
    catch (err) {
        error(res, 400, err.message, `${req.version}/captcha`);
    }
});
// GET chart error
router.get('/:version/chart', (_req, res) => {
    error(res, 405, 'This endpoint only supports POST requests.');
});
// Display stored data
router.get('/:version/chat', (req, res) => {
    try {
        const messages = req.module.chat('fetch', {
            username: 'system',
            storage: chatStorage,
        });
        res.jsonResponse(messages);
    }
    catch (err) {
        error(res, 400, err.message);
    }
});
// GET private chat error
router.get('/:version/chat/private', (_req, res) => {
    error(res, 405, 'This endpoint only supports POST requests.');
});
// Generate color
router.get('/:version/color', (req, res) => {
    try {
        if (since(req.version, 4)) {
            const colorFn = req.module.color;
            const hex = req.query.hex;
            const result = colorFn(hex || undefined);
            res.jsonResponse(result);
        }
        else {
            const result = req.module.color();
            res.jsonResponse(result);
        }
    }
    catch (err) {
        error(res, 400, err.message, `${req.version}/color`);
    }
});
// Convert units
router.get('/:version/convert', (req, res) => {
    const { value, from, to } = req.query;
    if (!value || isNaN(Number(value))) {
        error(res, 400, 'Please provide a valid value (?value={value})', `${req.version}/convert`);
        return;
    }
    if (!from) {
        error(res, 400, 'Please provide a valid source unit (&from={unit})', `${req.version}/convert`);
        return;
    }
    if (!to) {
        error(res, 400, 'Please provide a valid target unit (&to={unit})', `${req.version}/convert`);
        return;
    }
    try {
        if (since(req.version, 4)) {
            const convertFn = req.module.convert;
            const result = convertFn(Number(value), from, to);
            res.jsonResponse(result);
        }
        else {
            const result = req.module.convert(value, from, to);
            res.jsonResponse(result);
        }
    }
    catch (err) {
        error(res, 400, err.message, `${req.version}/convert`);
    }
});
// Generate fictitious credit card numbers
router.get('/:version/credit', (req, res) => {
    const creditFn = req.module
        .credit;
    if (!creditFn) {
        error(res, 404, `Endpoint not available in ${req.version}.`, `${req.latest}/credit`);
        return;
    }
    const { brand, count, format } = req.query;
    try {
        const result = creditFn(brand, count !== undefined ? parseInt(count, 10) : 1, format);
        res.jsonResponse(result);
    }
    catch (err) {
        error(res, 400, err.message, `${req.version}/credit`);
    }
});
// Parse a cron expression and compute next execution dates
router.get('/:version/cron', (req, res) => {
    const { expr, count, from, timezone } = req.query;
    const { version } = req.params;
    const cronFn = req.module.cron;
    if (!cronFn) {
        error(res, 404, `Endpoint not available in ${version}.`, `${req.latest}/cron`);
        return;
    }
    if (!expr) {
        error(res, 400, 'Please provide a cron expression (?expr=* * * * *)', `${version}/cron`);
        return;
    }
    try {
        const result = cronFn(expr, count !== undefined ? parseInt(count, 10) : 5, from, timezone ?? 'UTC');
        res.jsonResponse(result);
    }
    catch (err) {
        error(res, 400, err.message, `${req.version}/cron`);
    }
});
// RPG Dice roller
router.get('/:version/dice', (req, res) => {
    const { roll } = req.query;
    const { version } = req.params;
    const dice = req.module.dice;
    if (!dice) {
        error(res, 404, `Endpoint not available in ${version}.`, `${req.latest}/dice`);
        return;
    }
    if (!roll) {
        error(res, 400, 'Please provide a roll notation (?roll=2d6+3)', `${version}/dice`);
        return;
    }
    try {
        const result = dice(roll);
        res.jsonResponse(result);
    }
    catch (err) {
        error(res, 400, err.message, `${req.version}/dice`);
    }
});
// Generate domain informations
router.get('/:version/domain', (req, res) => {
    try {
        const result = req.module.domain();
        res.jsonResponse(result);
    }
    catch (err) {
        error(res, 400, err.message, `${req.version}/domain`);
    }
});
// Encode / decode text
router.get('/:version/encode', (req, res) => {
    const { method, text, shift } = req.query;
    const { version } = req.params;
    const encode = req.module.encode;
    if (!encode) {
        error(res, 404, `Endpoint not available in ${version}.`, `${req.latest}/encode`);
        return;
    }
    if (!method || !Object.hasOwn(encode, method)) {
        error(res, 400, 'Please provide a valid method (?method={method})', `${version}/encode`);
        return;
    }
    try {
        const result = encode[method](text, shift);
        res.jsonResponse({ method, result });
    }
    catch (err) {
        error(res, 400, err.message, `${req.version}/encode`);
    }
});
// Evaluate a math expression
router.get('/:version/evaluate', (req, res) => {
    const { expr, precision } = req.query;
    const { version } = req.params;
    const evaluateFn = req.module.evaluate;
    if (!evaluateFn) {
        error(res, 404, `Endpoint not available in ${version}.`, `${req.latest}/evaluate`);
        return;
    }
    if (!expr || typeof expr !== 'string') {
        error(res, 400, 'Please provide a math expression (?expr={expression})', `${version}/evaluate`);
        return;
    }
    try {
        const result = evaluateFn(expr, precision !== undefined ? parseInt(precision, 10) : undefined);
        res.jsonResponse(result);
    }
    catch (err) {
        error(res, 400, err.message, `${req.version}/evaluate`);
    }
});
// Geographic distance and bearing between two coordinates
router.get('/:version/geo', (req, res) => {
    const { lat1, lon1, lat2, lon2 } = req.query;
    const { version } = req.params;
    const geo = req.module.geo;
    if (!geo) {
        error(res, 404, `Endpoint not available in ${version}.`, `${req.latest}/geo`);
        return;
    }
    if (lat1 === undefined || lon1 === undefined || lat2 === undefined || lon2 === undefined) {
        error(res, 400, 'Please provide lat1, lon1, lat2 and lon2', `${version}/geo`);
        return;
    }
    try {
        const result = geo(lat1, lon1, lat2, lon2);
        res.jsonResponse(result);
    }
    catch (err) {
        error(res, 400, err.message, `${req.version}/geo`);
    }
});
// GET hash error
router.get('/:version/hash', (_req, res) => {
    error(res, 405, 'This endpoint only supports POST requests.');
});
// Echo request headers
router.get('/:version/headers', (req, res) => {
    const redacted = new Set(['authorization', 'cookie', 'set-cookie', 'proxy-authorization']);
    let headers = {};
    for (const [k, v] of Object.entries(req.headers)) {
        headers[k] = redacted.has(k) ? '[redacted]' : v;
    }
    const filter = req.query.filter;
    if (filter) {
        const keys = new Set(filter.split(',').map((k) => k.trim().toLowerCase()));
        headers = Object.fromEntries(Object.entries(headers).filter(([k]) => keys.has(k)));
    }
    res.jsonResponse({
        count: Object.keys(headers).length,
        headers,
        ip: req.ip,
        method: req.method,
        url: req.originalUrl,
    });
});
// GET planning error
router.get('/:version/hyperplanning', (_req, res) => {
    error(res, 405, 'This endpoint only supports POST requests.');
});
// Display API informations
router.get('/:version/infos', (req, res) => {
    const endpoints = Object.values(versions[req.version].endpoints).flat();
    const paths = endpoints.flatMap((e) => (e.children ? Object.values(e.children) : e.path ? [e.path] : []));
    res.jsonResponse({
        endpoints: new Set(paths).size,
        last_version: Object.keys(versions).pop(),
        documentation: DOCS_URL,
        github: 'https://github.com/20syldev/api',
        creation: 'November 25th 2024',
    });
});
// Analyze an IP address
router.get('/:version/ip', (req, res) => {
    const address = req.query.address ?? req.ip ?? '';
    try {
        const ipFn = req.module.ip;
        const result = ipFn(address);
        res.jsonResponse(result);
    }
    catch (err) {
        error(res, 400, err.message, `${req.version}/ip`);
    }
});
// Calculate Levenshtein distance
router.get('/:version/levenshtein', (req, res) => {
    const { str1, str2 } = req.query;
    if (!str1 || typeof str1 !== 'string') {
        error(res, 400, 'Please provide a first string (?str1={string})', `${req.version}/levenshtein`);
        return;
    }
    if (!str2 || typeof str2 !== 'string') {
        error(res, 400, 'Please provide a second string (&str2={string})', `${req.version}/levenshtein`);
        return;
    }
    try {
        const result = req.module.levenshtein(str1, str2);
        res.jsonResponse(result);
    }
    catch (err) {
        error(res, 400, err.message, `${req.version}/levenshtein`);
    }
});
// GET matrix error
router.get('/:version/matrix', (_req, res) => {
    error(res, 405, 'This endpoint only supports POST requests.');
});
// Generate a color palette from a base color
router.get('/:version/palette', (req, res) => {
    const { color, type } = req.query;
    const { version } = req.params;
    const palette = req.module.palette;
    if (!palette) {
        error(res, 404, `Endpoint not available in ${version}.`, `${req.latest}/palette`);
        return;
    }
    if (!color) {
        error(res, 400, 'Please provide a base color (?color=#ff6600)', `${version}/palette`);
        return;
    }
    if (!type) {
        error(res, 400, 'Please provide a palette type (&type=complementary)', `${version}/palette`);
        return;
    }
    try {
        const result = palette(color, type);
        res.jsonResponse(result);
    }
    catch (err) {
        error(res, 400, err.message, `${req.version}/palette`);
    }
});
// Generate a password or passphrase
router.get('/:version/password', (req, res) => {
    const { type, length, uppercase, lowercase, digits, symbols, exclude, count, separator } = req.query;
    const { version } = req.params;
    const passwordFn = req.module.password;
    if (!passwordFn) {
        error(res, 404, `Endpoint not available in ${version}.`, `${req.latest}/password`);
        return;
    }
    const parseBool = (v, def) => (v === undefined ? def : v !== 'false');
    try {
        const result = passwordFn(type ?? 'random', length !== undefined ? parseInt(length, 10) : 16, {
            uppercase: parseBool(uppercase, true),
            lowercase: parseBool(lowercase, true),
            digits: parseBool(digits, true),
            symbols: parseBool(symbols, false),
            exclude: exclude ?? '',
            count: count !== undefined ? parseInt(count, 10) : 1,
            separator: separator ?? '-',
        });
        res.jsonResponse(result);
    }
    catch (err) {
        error(res, 400, err.message, `${req.version}/password`);
    }
});
// Generate personal data
router.get('/:version/personal', (req, res) => {
    try {
        const result = req.module.personal();
        res.jsonResponse(result);
    }
    catch (err) {
        error(res, 400, err.message, `${req.version}/personal`);
    }
});
// Generate a placeholder image or skeleton
router.get('/:version/placeholder', (req, res) => {
    const { type = 'image' } = req.query;
    const { version } = req.params;
    const placeholder = req.module.placeholder;
    if (!placeholder) {
        error(res, 404, `Endpoint not available in ${version}.`, `${req.latest}/placeholder`);
        return;
    }
    try {
        const result = placeholder(type, req.query);
        res.type(result.contentType).send(result.body);
    }
    catch (err) {
        error(res, 400, err.message, `${req.version}/placeholder`);
    }
});
// Generate QR Code
router.get('/:version/qrcode', async (req, res) => {
    const { url } = req.query;
    if (!url) {
        error(res, 400, 'Please provide a valid url (?url={URL})', `${req.version}/qrcode`);
        return;
    }
    try {
        if (since(req.version, 4)) {
            const qrcodeFn = req.module.qrcode;
            const result = await qrcodeFn({
                url: url,
                size: req.query.size ? Number(req.query.size) : undefined,
                margin: req.query.margin ? Number(req.query.margin) : undefined,
                correction: req.query.correction,
                dark: req.query.dark,
                light: req.query.light,
                icon: req.query.icon,
                iconSize: req.query.iconSize ? Number(req.query.iconSize) : undefined,
                iconPadding: req.query.iconPadding ? Number(req.query.iconPadding) : undefined,
                iconRadius: req.query.iconRadius ? Number(req.query.iconRadius) : undefined,
                format: req.query.format,
            });
            if (result.contentType === 'application/json') {
                res.jsonResponse(result.body);
            }
            else {
                res.type(result.contentType).send(result.body);
            }
        }
        else {
            const result = await req.module.qrcode(url);
            res.jsonResponse(result);
        }
    }
    catch (err) {
        error(res, 400, err.message, `${req.version}/qrcode`);
    }
});
// Test a regex pattern against a text
router.get('/:version/regex', (req, res) => {
    const { pattern, text, flags } = req.query;
    const { version } = req.params;
    const regexFn = req.module.regex;
    if (!regexFn) {
        error(res, 404, `Endpoint not available in ${version}.`, `${req.latest}/regex`);
        return;
    }
    if (!pattern) {
        error(res, 400, 'Please provide a pattern (?pattern={regex})', `${version}/regex`);
        return;
    }
    if (!text) {
        error(res, 400, 'Please provide a text (&text={string})', `${version}/regex`);
        return;
    }
    try {
        const result = regexFn(pattern, text, flags);
        res.jsonResponse(result);
    }
    catch (err) {
        error(res, 400, err.message, `${req.version}/regex`);
    }
});
// Statistics on a list of numbers
router.get('/:version/statistics', (req, res) => {
    const { values } = req.query;
    const { version } = req.params;
    const statistics = req.module.statistics;
    if (!statistics) {
        error(res, 404, `Endpoint not available in ${version}.`, `${req.latest}/statistics`);
        return;
    }
    if (!values) {
        error(res, 400, 'Please provide a list of values (?values=1,2,3)', `${version}/statistics`);
        return;
    }
    try {
        const result = statistics(values);
        res.jsonResponse(result);
    }
    catch (err) {
        error(res, 400, err.message, `${req.version}/statistics`);
    }
});
// Text utilities (slug, stats, lorem, number)
router.get('/:version/text', (req, res) => {
    const { method, value, type, count, lang, text } = req.query;
    const { version } = req.params;
    const textMod = req.module.text;
    if (!textMod) {
        error(res, 404, `Endpoint not available in ${version}.`, `${req.latest}/text`);
        return;
    }
    if (!method || !Object.hasOwn(textMod, method)) {
        error(res, 400, 'Please provide a valid method (?method={slug|stats|lorem|number})', `${version}/text`);
        return;
    }
    try {
        let result;
        switch (method) {
            case 'slug':
            case 'stats':
                result = textMod[method]((value ?? text));
                break;
            case 'lorem':
                result = textMod.lorem(type || 'words', count || '5');
                break;
            case 'number':
                result = textMod.number(value, lang || 'en');
                break;
            default:
                throw new Error('Unknown method');
        }
        res.jsonResponse({ method, result });
    }
    catch (err) {
        error(res, 400, err.message, `${req.version}/text`);
    }
});
// GET tic-tac-toe errors
router.get('/:version/tic-tac-toe', (_req, res) => {
    error(res, 405, 'This endpoint only supports POST requests.');
});
router.get('/:version/tic-tac-toe/fetch', (_req, res) => {
    error(res, 405, 'This endpoint only supports POST requests.');
});
router.get('/:version/tic-tac-toe/list', (_req, res) => {
    error(res, 405, 'This endpoint only supports POST requests.');
});
// Display or generate time informations, or compute a countdown
router.get('/:version/time', (req, res) => {
    const { type = 'live', start, end, format, timezone, target } = req.query;
    try {
        const timeFn = req.module.time;
        const time = timeFn(type, start, end, format, timezone, target);
        res.jsonResponse(time);
    }
    catch (err) {
        error(res, 400, err.message, `${req.version}/time`);
    }
});
// GET token error
router.get('/:version/token', (_req, res) => {
    error(res, 405, 'This endpoint only supports POST requests.');
});
// Generate username
router.get('/:version/username', (req, res) => {
    try {
        const result = req.module.username();
        res.jsonResponse(result);
    }
    catch (err) {
        error(res, 400, err.message, `${req.version}/username`);
    }
});
// Validate data (luhn, iban, email)
router.get('/:version/validate', (req, res) => {
    const { type, value } = req.query;
    const { version } = req.params;
    const validate = req.module.validate;
    if (!validate) {
        error(res, 404, `Endpoint not available in ${version}.`, `${req.latest}/validate`);
        return;
    }
    if (!type || !Object.hasOwn(validate, type)) {
        error(res, 400, 'Please provide a valid type (?type={luhn|iban|email})', `${version}/validate`);
        return;
    }
    if (!value) {
        error(res, 400, 'Please provide a value (&value={value})', `${version}/validate`);
        return;
    }
    try {
        const result = validate[type](value);
        res.jsonResponse(result);
    }
    catch (err) {
        error(res, 400, err.message, `${req.version}/validate`);
    }
});
// Display informations for owner's website
router.get('/:version/website', async (req, res) => {
    const currentTime = Date.now();
    if (currentTime - lastFetch >= GITHUB_CACHE_TTL) {
        try {
            const username = '20syldev';
            const token = env.GITHUB_TOKEN;
            const lastYear = new Date(new Date().setFullYear(new Date().getFullYear() - 1)).toISOString().split('T')[0];
            const query = `
            {
              user(login: "${username}") {
                contributionsCollection(from: "${lastYear}T00:00:00Z") {
                  contributionCalendar {
                    totalContributions
                    weeks {
                      firstDay
                      contributionDays {
                        date
                        contributionCount
                      }
                    }
                  }
                }
              }
            }`;
            const apiResponse = await fetch('https://api.github.com/graphql', {
                method: 'POST',
                headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
                body: JSON.stringify({ query }),
            });
            if (!apiResponse.ok)
                throw new Error('Error fetching data.');
            const data = (await apiResponse.json());
            const user = data?.data?.user;
            const weeks = user?.contributionsCollection?.contributionCalendar?.weeks || [];
            activity = weeks.map((w) => ({
                week: w.firstDay,
                total: w.contributionDays.reduce((sum, d) => sum + d.contributionCount, 0),
                days: w.contributionDays.map((d) => ({ date: d.date, count: d.contributionCount })),
            }));
            lastFetch = currentTime;
        }
        catch {
            activity = [];
        }
    }
    const response = {
        versions: {
            2048: env.G_2048,
            api: env.API,
            cdn: env.CDN,
            coop_api: env.COOP_API,
            coop_status: env.COOP_STATUS,
            chat: env.CHAT,
            digit: env.DIGIT,
            doc_coopbot: env.DOC_COOPBOT,
            docs: env.DOCS,
            donut: env.DONUT,
            drawio_plugin: env.DRAWIO_PLUGIN,
            flowers: env.FLOWERS,
            gemsync: env.GEMSYNC,
            gft: env.GFT,
            gitsite: env.GITSITE,
            lebonchar: env.LEBONCHAR,
            logger: env.LOGGER,
            logs: env.LOGS,
            logvault: env.LOGVAULT,
            lyah: env.LYAH,
            minify: env.MINIFY,
            mn: env.MN,
            monitoring: env.MONITORING,
            morpion: env.MORPION,
            nitrogen: env.NITROGEN,
            old_database: env.OLD_DATABASE,
            password: env.PASSWORD,
            php: env.PHP,
            planning: env.PLANNING,
            ping: env.PING,
            portfolio: env.PORTFOLIO,
            python_api: env.PYTHON_API,
            readme: env.README,
            timestamp: env.TIMESTAMP,
            terminal: env.TERMINAL,
            valentine: env.VALENTINE,
            wrkit: env.WRKIT,
            zpki: env.ZPKI,
        },
        patched_projects: env.PATCH,
        updated_projects: env.RECENT,
        new_projects: env.NEW,
        sub_domains: env.DOMAINS,
        stats: {
            1: env.STATS1,
            2: env.STATS2,
            3: env.STATS3,
            4: env.STATS4,
            5: Object.keys(ipLimits).length,
            activity,
        },
        tag: env.TAG,
        active: env.ACTIVE,
    };
    const key = req.query.key;
    if (key) {
        if (['__proto__', 'constructor', 'prototype'].some((p) => key.includes(p))) {
            error(res, 400, 'Invalid key.');
            return;
        }
        const keys = key.split('.');
        let result = response;
        for (const k of keys) {
            if (result == null || typeof result !== 'object' || !(k in result)) {
                error(res, 404, `Key '${key}' not found.`);
                return;
            }
            result = result[k];
        }
        res.jsonResponse({ [key]: result });
        return;
    }
    res.jsonResponse(response);
});
export default router;
//# sourceMappingURL=get.js.map