import { ResponseToolkit, Server } from "@hapi/hapi";
import dbWorks from "../dbWorks";

const apiRoutes = {
  name: "api_routes_plugin",
  version: "1.0.0",
  register: async function (server: Server, options: any) {
    server.route({
      method: "POST",
      path: "/api/signin",
      handler: (request, h) => {
        // @ts-ignore
        return request.payload.username;
      },
      options: {
        payload: {
          multipart: { output: "stream" },
          parse: true,
          allow: "multipart/form-data",
        },
      },
    });

    server.route({
      method: "POST",
      path: "/api/signup",
      handler: (request, h) => {
        // @ts-ignore
        return request.payload.username;
      },
      options: {
        payload: {
          multipart: { output: "stream" },
          parse: true,
          allow: "multipart/form-data",
        },
      },
    });
    server.route({
      method: "POST",
      path: "/api/post-car",
      handler: async (request,h) => {
        return "ok";
      },
    });
    server.route({
      method: "GET",
      path: "/api/get-buyable-cars",
      handler: async (request,h) => {
        const res = await dbWorks.getAllAvilableCarsToBuy()
        return res
      },
    });
    server.route({
      method: 'GET',
      path: "/api/users/:username",
      handler: async (request,h) => {
       const  res = await dbWorks.getUserRecordByName(request.params.username);
       return res[0]
      },
    });
    server.route({
      method: "POST",
      path: "/api/post-car",
      handler: async (req,h) => {
        return "ok";
      },
    });
    server.route({
      method: "POST",
      path: "/api/set-car-sold/:carID",
      handler: async (req,h) => {
        await dbWorks.setCarSold(req.params.carID)
        return "ok";
      },
    });
  },
};

export { apiRoutes };
