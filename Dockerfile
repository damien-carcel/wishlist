FROM node:slim

RUN npm install netlify-cli -g

EXPOSE 3000
