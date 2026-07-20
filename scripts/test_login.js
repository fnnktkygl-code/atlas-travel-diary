const puppeteer = require('puppeteer');
const fs = require('fs');

(async () => {
  const browser = await puppeteer.launch({ 
    headless: true,
    args: ['--disable-web-security', '--disable-features=IsolateOrigins,site-per-process']
  });
  const page = await browser.newPage();
  
  // Create scratch dir for screenshots
  fs.mkdirSync('/Users/richard/.gemini/antigravity-ide/brain/3f24ad19-f51e-42cb-b016-aea953b40729/scratch', { recursive: true });
  
  console.log("Navigating to atlas-ashy-six.vercel.app...");
  await page.goto('https://atlas-ashy-six.vercel.app', { waitUntil: 'networkidle0' });
  
  console.log("Waiting 5s for CanvasKit to render...");
  await new Promise(r => setTimeout(r, 5000));
  
  await page.screenshot({ path: '/Users/richard/.gemini/antigravity-ide/brain/3f24ad19-f51e-42cb-b016-aea953b40729/scratch/step1_loaded.png' });
  
  // The profile icon is usually at the top right. 
  // Let's click at coordinates near the top right. 
  // Assuming viewport is 800x600, top right is near (760, 40)
  console.log("Clicking profile icon...");
  await page.mouse.click(760, 40);
  await new Promise(r => setTimeout(r, 2000));
  
  await page.screenshot({ path: '/Users/richard/.gemini/antigravity-ide/brain/3f24ad19-f51e-42cb-b016-aea953b40729/scratch/step2_modal.png' });
  
  // The "Se connecter" button is in the modal.
  // We can try to click the center of the screen since the modal is centered.
  // Wait, the modal is an AlertDialog or similar? Usually centered.
  // Let's click around the center slightly lower.
  console.log("Clicking login button...");
  await page.mouse.click(400, 350);
  await new Promise(r => setTimeout(r, 2000));
  
  await page.screenshot({ path: '/Users/richard/.gemini/antigravity-ide/brain/3f24ad19-f51e-42cb-b016-aea953b40729/scratch/step3_clicked.png' });
  
  // If it redirects, the URL will change.
  console.log("Current URL:", page.url());
  
  await browser.close();
})();
