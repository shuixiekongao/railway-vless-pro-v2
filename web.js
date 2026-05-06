const express = require("express");
const app = express();
const PORT = 3000;

app.use(express.static("public"));

function node(){
  const uuid = process.env.UUID;
  const domain = process.env.DOMAIN;

  return `vless://${uuid}@${domain}:443?encryption=none&security=tls&sni=${domain}&type=xhttp&host=${domain}&path=%2Fvless#FLAGSHIP`;
}

app.get("/", (req,res)=>{
  res.send(`
  <h2>VLESS FLAGSHIP PANEL</h2>
  <p>Domain: ${process.env.DOMAIN}</p>
  <textarea style="width:100%;height:120px;">${node()}</textarea>
  <p><a href="/sub">SUB</a> | <a href="/info">INFO</a></p>
  `);
});

app.get("/sub",(req,res)=>{
  res.send(node());
});

app.get("/info",(req,res)=>{
  res.json({
    name:"VLESS FLAGSHIP",
    status:"online",
    protocol:"xhttp",
    domain:process.env.DOMAIN,
    sub:`https://${process.env.DOMAIN}/sub`
  });
});

app.get("/health",(req,res)=>res.send("ok"));

app.listen(PORT,()=>console.log("web on "+PORT));
