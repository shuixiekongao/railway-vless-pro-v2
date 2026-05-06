const express = require("express");
const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.static("public"));

function getNode(){
  const uuid = process.env.UUID;
  const domain = process.env.DOMAIN;
  return `vless://${uuid}@${domain}:443?encryption=none&security=tls&sni=${domain}&type=xhttp&host=${domain}&path=%2Fvless#Railway-Argo-Flagship`;
}

app.get("/", (req,res)=>{
  res.send(`
  <html>
  <head>
  <title>Railway Argo VLESS Flagship</title>
  <style>
  body{font-family:Arial;background:#111;color:#0f0;padding:30px;}
  a{color:#0ff;}
  textarea{width:100%;height:120px;}
  </style>
  </head>
  <body>
    <h2>Railway Argo VLESS Flagship Online</h2>
    <p>Status: Running</p>
    <p>Domain: ${process.env.DOMAIN}</p>
    <p>UUID: ${process.env.UUID}</p>
    <h3>Node Subscription</h3>
    <textarea>${getNode()}</textarea>
    <p><a href="/sub">/sub</a> | <a href="/info">/info</a> | <a href="/health">/health</a></p>
  </body>
  </html>
  `);
});

app.get("/sub",(req,res)=>{
  res.send(getNode());
});

app.get("/info",(req,res)=>{
  res.json({
    name:"Railway Argo VLESS Flagship",
    status:"online",
    protocol:"xhttp",
    keepalive:"enabled",
    domain:process.env.DOMAIN,
    subscription:`https://${process.env.DOMAIN}/sub`
  });
});

app.get("/health",(req,res)=>res.send("ok"));

app.listen(PORT,()=>console.log("Web panel running on "+PORT));
