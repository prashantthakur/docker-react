FROM node:alpine as builder
WORKDIR '/app'
COPY package.json .
RUN npm install
COPY . .
RUN npm run build

FROM nginx
#Elastic bean stalk would listen on this port and map the external incoming request to this port
EXPOSE 80
COPY --from=builder /app/build /usr/share/nginx/html

