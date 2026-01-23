const express = require('express');
const multer = require('multer');
const path = require('path');

const app = express();
const port = 3000;

/* Multer storage configuration */
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/');
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + '-' + file.originalname);
  }
});

const upload = multer({ storage: storage });

/* Home page */
app.get('/', (req, res) => {
  res.send(`
  <!DOCTYPE html>
  <html>
  <head>
    <title>File Upload</title>
    <style>
      body {
        font-family: Arial;
        background: #1e1e2f;
        color: white;
        display: flex;
        justify-content: center;
        align-items: center;
        height: 100vh;
      }
      .box {
        background: #2a2a40;
        padding: 30px;
        border-radius: 12px;
        text-align: center;
        width: 350px;
      }
      input, button {
        margin-top: 15px;
      }
      button {
        padding: 8px 16px;
        background: #667eea;
        border: none;
        color: white;
        cursor: pointer;
        border-radius: 6px;
      }
    </style>
  </head>
  <body>
    <div class="box">
      <h2>📁 Upload a File</h2>
      <form action="/upload" method="post" enctype="multipart/form-data">
        <input type="file" name="file" required /><br/>
        <button type="submit">Upload</button>
      </form>
      <p>Deployed on AWS ECS Fargate</p>
    </div>
  </body>
  </html>
  `);
});

/* File upload endpoint */
app.post('/upload', upload.single('file'), (req, res) => {
  if (!req.file) {
    return res.send('No file uploaded');
  }
  res.send(`
    <h2>✅ File Uploaded Successfully</h2>
    <p>Filename: ${req.file.filename}</p>
    <a href="/">Go Back</a>
  `);
});

app.listen(port, '0.0.0.0', () => {
  console.log(`Server running on port ${port}`);
});
