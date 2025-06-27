import { config as loadenv } from "dotenv";

loadenv();

const SERVER_IP = "127.0.0.1";
const SERVER_PORT = 3000;

const serverConfig = { serverIP: SERVER_IP, serverPort: SERVER_PORT };

const DB_NAME = "node";
const DB_HOST = "127.0.0.1";
const DB_PORT = "5432";
const DB_USER = "noor";
const DB_PASSWORD = "node";

const dbConfig = {
  dbName: DB_NAME,
  dbHost: DB_HOST,
  dbPort: DB_PORT,
  dbUser: DB_USER,
  dbPassword: DB_PASSWORD,
};

// auth

// jwt

// hash

export const config = { serverConfig: serverConfig, dbConfig: dbConfig };
