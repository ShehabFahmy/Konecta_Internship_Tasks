FROM node:latest AS build

WORKDIR /app

COPY package*.json .

RUN npm install --only=production

# Done after npm install so it doesn't re-create the same layers if the source code is changed 
COPY . .


FROM node:slim AS runtime

WORKDIR /app

COPY --from=build /app /app

EXPOSE 3000

CMD ["npm", "start"]
