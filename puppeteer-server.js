const express = require('express');
const puppeteer = require('puppeteer');

const app = express();
app.use(express.json());

let browserPromise = puppeteer.launch({
    executablePath: '/usr/bin/chromium-browser',
    args: [
        '--no-sandbox',
        '--disable-setuid-sandbox',
        '--disable-dev-shm-usage',
        '--disable-gpu',
        '--headless=new'
    ],
});

app.post('/register', async (req, res) => {
    const { email, password, site } = req.body;

    try {
        const browser = await browserPromise;
        const page = await browser.newPage();
        await page.goto(site, { waitUntil: 'networkidle2' });
        await page.type('#email', email);
        await page.type('#password', password);
        await page.click('button[type="submit"]');
        await page.waitForNavigation();

        // Optional: take screenshot for proof
        await page.screenshot({ path: `/app/success-${Date.now()}.png` });

        await page.close();
        return res.json({ success: true, message: 'Registered like a ghost.' });
    } catch (err) {
        return res.status(500).json({ error: err.message });
    }
});

app.post('/clear', async (req, res) => {
    const browser = await browserPromise;
    await browser.close();
    await browserPromise; // Restart
    return res.json({ status: 'Browser nuked.' });
});

app.listen(3000, () => {
    console.log('🔥 Puppeteer Automation Server Running on :3000');
});
