const express = require("express");
const app = express();
const PORT = process.env.PORT || 3000;
app.use(express.static("public"));

app.get("/sub",(req,res)=>{
 const uuid=process.env.UUID;
 const domain=process.env.DOMAIN;
 res.send(`vless://${uuid}@${domain}:443?encryption=none&security=tls&sni=${domain}&type=ws&host=${domain}&path=%2Fvless#Railway-Argo-ProV2`);
});

app.get("/info",(req,res)=>{
 res.json({
   name:"Railway Argo VLESS Pro V2",
   status:"online",
   keepalive:"enabled",
   domain:process.env.DOMAIN,
   subscription:`https://${process.env.DOMAIN}/sub`
 });
});

app.get("/health",(req,res)=>res.send("ok"));

app.listen(PORT,()=>console.log("Web panel running on "+PORT));