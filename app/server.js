const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send(`
<!DOCTYPE html>
<html>
<head>
  <title>My Cloud App</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      background: linear-gradient(135deg, #667eea, #764ba2);
      height: 100vh;
      margin: 0;
      display: flex;
      justify-content: center;
      align-items: center;
      color: white;
    }
    .card {
      background: rgba(255, 255, 255, 0.15);
      padding: 40px;
      border-radius: 16px;
      text-align: center;
      box-shadow: 0 10px 30px rgba(0,0,0,0.3);
      max-width: 400px;
    }
    h1 {
      margin-bottom: 10px;
    }
    p {
      font-size: 18px;
    }
    .tag {
      margin-top: 20px;
      font-size: 14px;
      opacity: 0.9;
    }
  </style>
</head>
<body>
  <div class="card">
    <h1>Hello from Node Server</h1>
    <p>Deployed on <b>AWS ECS Fargate</b></p>
    <p>by <b>Thimeth</b></p>
    <div class="tag">CI/CD • Docker • Terraform • AWS</div>
  </div>
</body>
</html>
`);
});


app.listen(port, '0.0.0.0', () => {
  console.log(`Server running on port ${port}`);
});
