import { ResponseToolkit, Server } from "@hapi/hapi";

const topLevelRoutes = {
  name: "top-level_routes_plugin",
  version: "1.0.0",
  register: async function (server: Server, options: any) {
    server.route({
      method: "POST",
      path: "/api/signin",
      handler: (request, h) => {
        // @ts-ignore
        return request.payload.username;
      },
    });

    server.route({
      method: "POST",
      path: "/api/signup",
      handler: (request, h) => {
        // @ts-ignore
        return request.payload.username;
      },
    });
  },
};

export default { topLevelRoutes };
