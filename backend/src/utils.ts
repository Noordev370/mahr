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
  return jwt.verify(token, config.jwtConfig.secret, (err, token) => {
    if (err) {
      return "error";
    } else {
      return token;
    }
  });
}

async function uploadFile(stream: ReadableStream) {
  return 0;
}

export default { jwtSign, jwtVerify };
