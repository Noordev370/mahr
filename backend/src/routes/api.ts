import { ResponseToolkit, Server } from "@hapi/hapi";
import boom from "@hapi/boom";
import { createWriteStream } from "fs";
import path from "path";
import dbWorks from "../dbWorks";
import utils from "../utils";

const apiRoutes = {
  name: "api_routes_plugin",
  version: "1.0.0",
  routes: { cors: { origin: ["*"] } },
  register: async function(server: Server, options: any) {
    server.route({
      method: "POST",
      path: "/api/sign-in",
      options: {
        payload: {
          timeout: 2000,
          multipart: { output: "stream" },
          parse: true,
          allow: "multipart/form-data",
        },
      },
      handler: async (request, h) => {
        const payload: any = request.payload;
        const password = await dbWorks.getUserPasswordByName(payload.username);
        if (password === payload.password) {
          return utils.jwtSign(payload.username);
        } else {
          throw boom.unauthorized();
        }
      },
    });

    server.route({
      method: "POST",
      path: "/api/sign-up",
      handler: async (request, h) => {
        const payload: any = request.payload;
        await dbWorks.createUser({
          username: payload.username,
          password: payload.password,
          picture_file_name: payload.profile_picture.hapi.filename,
          bio: payload.bio,
        });
        if (!payload.profile_picture) {
          throw boom.badRequest;
        }
        const uploadedFileStream = createWriteStream(
          path.resolve(
            process.cwd(),
            "./uploads",
            payload.profile_picture.hapi.filename,
          ),
        );
        return new Promise((resolve, reject) => {
          payload.profile_picture
            .pipe(uploadedFileStream)
            .on("error", (err: any) => console.log(err))
            .on("finish", () => {
              resolve(utils.jwtSign(payload.username));
            });
        });
      },
      options: {
        payload: {
          timeout: 2000,
          multipart: { output: "stream" },
          parse: true,
          allow: "multipart/form-data",
        },
      },
    });
    server.route({
      method: "POST",
      path: "/api/post-car",
      options: {
        payload: {
          timeout: 2000,
          multipart: { output: "stream" },
          parse: true,
          allow: "multipart/form-data",
        },
      },
      handler: async (request, h) => {
        const payload: any = request.payload;
        await dbWorks.postCar({
          mark: payload.mark,
          price: payload.price,
          model: payload.model,
          color: payload.color,
          status: "available",
          picture_file_name: payload.picture.hapi.filename,
        });
        if (!payload.picture) {
          throw boom.badRequest;
        }
        const uploadedFileStream = createWriteStream(
          path.resolve(
            process.cwd(),
            "./uploads",
            payload.picture.hapi.filename,
          ),
        );
        return new Promise((resolve, reject) => {
          payload.picture
            .pipe(uploadedFileStream)
            .on("error", (err: any) => console.log(err))
            .on("finish", () => {
              resolve("ok");
            });
        });
      },
    });
    server.route({
      method: "GET",
      path: "/api/get-buyable-cars",
      handler: async (request, h) => {
        const res = await dbWorks.getAllAvilableCarsToBuy();
        return res;
      },
    });
    server.route({
      method: "GET",
      path: "/api/profile/:username",
      handler: async (request, h) => {
        const res = await dbWorks.getUserRecordByName(request.params.username);
        return res[0];
      },
    });
    server.route({
      method: "POST",
      path: "/api/set-car-sold/:carID",
      handler: async (req, h) => {
        await dbWorks.setCarSold(req.params.carID);
        return "ok";
      },
    });
  },
};

export { apiRoutes };
