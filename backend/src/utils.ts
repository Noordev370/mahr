import jwt from "jsonwebtoken";
import config from "./config";

function jwtSign(payload: string) {
  try {
    return jwt.sign(payload, config.jwtConfig.secret);
  } catch (err) {
    console.log(err);
    return "error";
  }
}

async function jwtVerify(token: string) {
  try {
    jwt.verify(token, config.jwtConfig.secret);
    return true;
  } catch {
    return false;
  }
}

async function uploadFile(stream: ReadableStream) {
  return 0;
}

export default { jwtSign, jwtVerify };
