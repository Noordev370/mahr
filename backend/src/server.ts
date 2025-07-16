import Hapi from "@hapi/hapi";
import inert from "@hapi/inert";
import Path from "path";
import { apiRoutes } from "./routes/api";
import config from "./config";

const init = async () => {
  const server = Hapi.server({
    port: config.serverConfig.serverPort,
    host: "0.0.0.0",
    debug: { request: ["error", "uncaught"] },
    routes: {
      files: { relativeTo: Path.join("/home/noor/mahr/backend", "static") },
      payload: { maxBytes: 2 * 1024 * 1024 },
    },
  });

  await server.register(inert);
  await server.register({ plugin: apiRoutes });

  server.route({
    method: "GET",
    path: "/",
    handler: (_, h) => {
      return h.file("../static/html/home.html");
    },
  });

  server.route({
    method: "GET",
    path: "/static/{param*}",
    handler: { directory: { path: "." } },
  });

  server.route({
    method: "GET",
    path: "/uploads/{param*}",
    options: {
      files: { relativeTo: Path.join("/home/noor/mahr/backend", "uploads") },
    },
    handler: { directory: { path: "." } },
  });

  server.route({
    method: "GET",
    path: "/profile/{username}",
    handler: (req, h) => {
      return h.file("../static/html/profile.html");
    },
  });

  server.route({
    method: "GET",
    path: "/sign-up",
    handler: (req, h) => {
      return h.file("../static/html/sign-up.html");
    },
  });
  server.route({
    method: "GET",
    path: "/sign-in",
    handler: (req, h) => {
      return h.file("../static/html/sign-in.html");
    },
  });
  server.route({
    method: "GET",
    path: "/search-cars",
    handler: (req, h) => {
      return h.file("html/search-cars.html");
    },
  });
  server.route({
    method: "GET",
    path: "/post-car",
    handler: async (request, h) => {
      return h.file("html/post-car.html");
    },
  });

  await server.start();
  console.log("Server running on http://127.0.0.1:3000/");
};

process.on("unhandledRejection", (err) => {
  console.error(err);
  process.exit(1);
});

init();
