import { Router } from 'express';
import { MAX_TOKEN_LENGTH, MIN_TOKEN_LENGTH } from '../constants.js';
import { chatStorage, ticTacToeStorage } from '../storage/index.js';
import { since } from '../utils/helpers.js';
import { error } from '../utils/response.js';
const router = Router();
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