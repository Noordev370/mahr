import Hapi from "@hapi/hapi";
import inert from "@hapi/inert";
import Path from "path";
import { apiRoutes } from "./routes/api";
import config from "./config";
import utils from "./utils";

const init = async () => {
  const server = Hapi.server({
    port: config.serverConfig.serverPort,
    host: config.serverConfig.serverIP,
    routes: {
      files: { relativeTo: Path.join("/home/noor/mahr/backend", "static") },
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
    path: "/profile",
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
      const authHeader = request.headers.authorization;
      const jwtToken = authHeader.replace("Bearer ", "");
      console.log(jwtToken);
      if (await utils.jwtVerify(jwtToken)) {
        return h.redirect("/sign-in");
      } else {
        return h.file("html/post-car.html");
      }
    },
  });

  await server.start();
  console.log("Server running on http://localhost:3000/");
};

process.on("unhandledRejection", (err) => {
  console.error(err);
  process.exit(1);
});

init();
