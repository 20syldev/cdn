import { Router } from 'express';
import { MAX_TOKEN_LENGTH, MIN_TOKEN_LENGTH } from '../constants.js';
import { chatStorage, ticTacToeStorage } from '../storage/index.js';
import { since } from '../utils/helpers.js';
import { error } from '../utils/response.js';
const router = Router();
// Asymmetric RSA key generation, encryption and decryption
router.post('/:version/asymmetric', (req, res) => {
    const body = req.body || {};
    const { action, text, publicKey, privateKey, modulusLength, algorithm } = body;
    const { version } = req.params;
    const asymmetricFn = req.module.asymmetric;
    if (!asymmetricFn) {
        error(res, 404, `Endpoint not available in ${version}.`, `${req.latest}/asymmetric`);
        return;
    }
    if (!action) {
        error(res, 400, 'Please provide an action (?action=keygen|encrypt|decrypt)', `${version}/asymmetric`);
        return;
    }
    try {
        const result = asymmetricFn(action, {
            text: text,
            publicKey: publicKey,
            privateKey: privateKey,
            modulusLength: modulusLength !== undefined ? Number(modulusLength) : undefined,
            algorithm: algorithm,
        });
        res.jsonResponse(result);
    }
    catch (err) {
        error(res, 400, err.message, `${req.version}/asymmetric`);
    }
});
// Generate a chart as SVG
router.post('/:version/chart', (req, res) => {
    const body = req.body || {};
    const { type, data, title, width, height, colors, bg, legend, mode } = body;
    const { version } = req.params;
    const chartMod = req.module.chart;
    if (!chartMod) {
        error(res, 404, `Endpoint not available in ${version}.`, `${req.latest}/chart`);
        return;
    }
    if (!type || typeof type !== 'string' || !Object.hasOwn(chartMod, type)) {
        error(res, 400, 'Please provide a valid chart type (?type=bar|line|pie|donut)', `${version}/chart`);
        return;
    }
    try {
        const output = chartMod[type](data, { title, width, height, colors, bg, legend, mode });
        if (output.contentType === 'application/json') {
            res.jsonResponse(output.body);
        }
        else {
            res.type(output.contentType).send(output.body);
        }
    }
    catch (err) {
        error(res, 400, err.message, `${req.version}/chart`);
    }
});
// Store chat messages
router.post('/:version/chat', (req, res) => {
    const { username, message, timestamp, session, token } = req.body || {};
    if (!username) {
        error(res, 400, 'Please provide a username (?username={username})');
        return;
    }
    if (!message) {
        error(res, 400, 'Please provide a message (&message={message})');
        return;
    }
    if (!session) {
        error(res, 400, 'Please provide a valid session ID (&session={ID})');
        return;
    }
    try {
        const result = req.module.chat('message', {
            username,
            message,
            timestamp,
            session,
            token,
            storage: chatStorage,
        });
        res.jsonResponse(result);
    }
    catch (err) {
        error(res, 400, err.message);
    }
});
// Display a private chat with a token
router.post('/:version/chat/private', (req, res) => {
    const { username, token } = req.body || {};
    if (!username) {
        error(res, 400, 'Please provide a username (?username={username})');
        return;
    }
    if (!token) {
        error(res, 400, 'Please provide a valid token (&token={key}).');
        return;
    }
    try {
        const messages = req.module.chat('private', {
            username,
            token,
            storage: chatStorage,
        });
        res.jsonResponse(messages);
    }
    catch (err) {
        error(res, 400, err.message);
    }
});
// Generate hash
router.post('/:version/hash', (req, res) => {
    const { text, method, encoding } = req.body || {};
    if (!text) {
        error(res, 400, 'Please provide a text (?text={text})', `${req.version}/hash`);
        return;
    }
    if (!method) {
        error(res, 400, 'Please provide a valid hash algorithm (&method={algorithm})', `${req.version}/hash`);
        return;
    }
    try {
        if (since(req.version, 4)) {
            const hashFn = req.module.hash;
            const result = hashFn(text, method, encoding);
            res.jsonResponse(result);
        }
        else {
            const result = req.module.hash(text, method);
            res.jsonResponse(result);
        }
    }
    catch (err) {
        error(res, 400, err.message, `${req.version}/hash`);
    }
});
// Display a planning from an ICS file
router.post('/:version/hyperplanning', async (req, res) => {
    const { url, detail } = req.body || {};
    if (!url) {
        error(res, 400, 'Please provide a valid ICS file URL (?url={URL})', `${req.version}/hyperplanning`);
        return;
    }
    try {
        const hyperplanning = await req.module.hyperplanning(url, detail);
        res.jsonResponse(hyperplanning);
    }
    catch (err) {
        error(res, 400, err.message, `${req.version}/hyperplanning`);
    }
});
// Matrix operations
router.post('/:version/matrix', (req, res) => {
    const body = req.body || {};
    const { operation, matrix: m, matrix2, scalar } = body;
    const { version } = req.params;
    const matrixMod = req.module.matrix;
    if (!matrixMod) {
        error(res, 404, `Endpoint not available in ${version}.`, `${req.latest}/matrix`);
        return;
    }
    if (!operation || typeof operation !== 'string' || !Object.hasOwn(matrixMod, operation)) {
        error(res, 400, 'Please provide a valid operation (?operation=add|subtract|multiply|scalar|transpose|determinant|inverse|identity)', `${version}/matrix`);
        return;
    }
    try {
        let result;
        switch (operation) {
            case 'add':
            case 'subtract':
            case 'multiply':
                result = matrixMod[operation](m, matrix2);
                break;
            case 'scalar':
                result = matrixMod.scalar(m, scalar);
                break;
            case 'transpose':
            case 'determinant':
            case 'inverse':
                result = matrixMod[operation](m);
                break;
            case 'identity':
                result = matrixMod.identity(scalar);
                break;
            default:
                throw new Error('Unknown operation');
        }
        res.jsonResponse(result);
    }
    catch (err) {
        error(res, 400, err.message, `${req.version}/matrix`);
    }
});
// Generate or verify OTP codes
router.post('/:version/otp', (req, res) => {
    const body = req.body || {};
    const { action, secret, code, algorithm, digits, period, counter, label, issuer } = body;
    const { version } = req.params;
    const otpFn = req.module.otp;
    if (!otpFn) {
        error(res, 404, `Endpoint not available in ${version}.`, `${req.latest}/otp`);
        return;
    }
    if (!action) {
        error(res, 400, 'Please provide an action (?action=secret|generate|verify)', `${version}/otp`);
        return;
    }
    try {
        const result = otpFn(action, {
            secret: secret,
            code: code,
            algorithm: algorithm,
            digits: digits !== undefined ? Number(digits) : undefined,
            period: period !== undefined ? Number(period) : undefined,
            counter: counter !== undefined ? Number(counter) : undefined,
            label: label,
            issuer: issuer,
        });
        res.jsonResponse(result);
    }
    catch (err) {
        error(res, 400, err.message, `${req.version}/otp`);
    }
});
// Symmetric encrypt or decrypt text
router.post('/:version/symmetric', (req, res) => {
    const body = req.body || {};
    const { action, text, key, algorithm } = body;
    const { version } = req.params;
    const symmetricFn = req.module
        .symmetric;
    if (!symmetricFn) {
        error(res, 404, `Endpoint not available in ${version}.`, `${req.latest}/symmetric`);
        return;
    }
    if (!action) {
        error(res, 400, 'Please provide an action (?action=encrypt|decrypt)', `${version}/symmetric`);
        return;
    }
    if (!text) {
        error(res, 400, 'Please provide a text (&text={text})', `${version}/symmetric`);
        return;
    }
    if (!key) {
        error(res, 400, 'Please provide a key (&key={key})', `${version}/symmetric`);
        return;
    }
    try {
        const result = symmetricFn(action, text, key, algorithm);
        res.jsonResponse(result);
    }
    catch (err) {
        error(res, 400, err.message, `${req.version}/symmetric`);
    }
});
// Store tic tac toe games
router.post('/:version/tic-tac-toe', (req, res) => {
    const { username, move, session, game } = req.body || {};
    if (!username) {
        error(res, 400, 'Please provide a username (?username={username})');
        return;
    }
    if (!move) {
        error(res, 400, 'Please provide a valid move (&move={move})');
        return;
    }
    if (!session) {
        error(res, 400, 'Please provide a valid session ID (&session={ID})');
        return;
    }
    if (!game) {
        error(res, 400, 'Please provide a valid game ID (&game={ID})');
        return;
    }
    try {
        const result = req.module.tic_tac_toe('play', {
            username,
            move,
            session,
            game,
            storage: ticTacToeStorage,
        });
        res.jsonResponse(result);
    }
    catch (err) {
        error(res, 400, err.message);
    }
});
// Display a tic tac toe game with a token
router.post('/:version/tic-tac-toe/fetch', (req, res) => {
    const { username, game } = req.body || {};
    const privateGame = (req.body || {}).private;
    if (!username) {
        error(res, 400, 'Please provide a username (?username={username})');
        return;
    }
    try {
        const result = req.module.tic_tac_toe('fetch', {
            username,
            game,
            private: privateGame,
            storage: ticTacToeStorage,
        });
        res.jsonResponse(result);
    }
    catch (err) {
        error(res, 400, err.message);
    }
});
// List public tic tac toe games
router.post('/:version/tic-tac-toe/list', (req, res) => {
    try {
        const result = req.module.tic_tac_toe('list', {
            storage: ticTacToeStorage,
        });
        res.jsonResponse(result);
    }
    catch (err) {
        error(res, 400, err.message);
    }
});
// Generate Token
router.post('/:version/token', (req, res) => {
    const body = req.body || {};
    const len = parseInt(String(body.len || 24), 10);
    const type = body.type ? String(body.type).toLowerCase() : 'alpha';
    if (isNaN(len) || len < 0) {
        error(res, 400, 'Invalid number.', `${req.version}/token`);
        return;
    }
    if (len > MAX_TOKEN_LENGTH) {
        error(res, 400, 'Length cannot exceed 4096.', `${req.version}/token`);
        return;
    }
    if (len < MIN_TOKEN_LENGTH) {
        error(res, 400, 'Length cannot be less than 12.', `${req.version}/token`);
        return;
    }
    try {
        const token = req.module.token(len, type);
        res.jsonResponse({ token });
    }
    catch (err) {
        error(res, 400, err.message, `${req.version}/token`);
    }
});
export default router;
//# sourceMappingURL=post.js.map