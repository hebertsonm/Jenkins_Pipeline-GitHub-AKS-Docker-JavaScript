from node:8-jessie

WORKDIR /usr/src/app

COPY app/ .

Expose 8000

RUN npm install --prod 


CMD [ "node", "bestbuy.ca.js"]
