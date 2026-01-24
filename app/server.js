const express = require('express');
const multer = require('multer');
const AWS = require('aws-sdk');

const app = express();
const port = 3000;

/* AWS S3 Configuration */
AWS.config.update({
  region: 'us-east-1'
});

const s3 = new AWS.S3();

/* Multer setup (store file in memory) */
const upload = multer({
  storage: multer.memoryStorage()
});

/* Home page */
app.get('/', (req, res) => {
  res.send(`
  <html>
  <head>
    <title>S3 File Upload</title>
    <style>
      body {
        font-family: Arial;
        background: #0f172a;
        color: white;
        display: flex;
        justify-content: center;
        align-items: center;
        height: 100vh;
      }
      .box {
        background: #1e293b;
        padding: 30px;
        border-radius: 12px;
        text-align: center;
        width: 360px;
      }
      button {
        margin-top: 15px;
        padding: 8px 16px;
        background: #38bdf8;
        border: none;
        border-radius: 6px;
        cursor: pointer;
      }
    </style>
  </head>
  <body>
    <div class="box">
      <h2>📤 Upload File to S3</h2>
      <form action="/upload" method="post" enctype="multipart/form-data">
        <input type="file" name="file" required /><br/>
        <button type="submit">Upload</button>
      </form>
      <p>AWS ECS + S3</p>
    </div>
  </body>
  </html>
  `);
});

/* Upload to S3 */
app.post('/upload', upload.single('file'), async (req, res) => {
  if (!req.file) {
    return res.send('No file uploaded');
  }

  const params = {
    Bucket: 'thimeth-file-upload-bucket',   // 👈 YOUR BUCKET NAME
    Key: `${Date.now()}-${req.file.originalname}`,
    Body: req.file.buffer
  };

  try {
    await s3.upload(params).promise();
    res.send(`
      <h2>✅ File Uploaded to S3</h2>
      <p>File name: ${params.Key}</p>
      <a href="/">Upload another file</a>
    `);
  } catch (error) {
    console.error(error);
    res.send('❌ Upload failed');
  }
});

app.listen(port, '0.0.0.0', () => {
  console.log(`Server running on port ${port}`);
});
