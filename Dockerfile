#sess 55   belwo part is called as  build-stage 
FROM node:20.19.5-alpine3.21 AS build
WORKDIR /opt/server
COPY package.json .
COPY *.js .
# this may add extra cache memory
RUN npm install
# upto above  build-stage 


FROM node:20.19.5-alpine3.21
# Create a group and user
WORKDIR /opt/server
USER roboshop
RUN addgroup -S roboshop && adduser -S roboshop -G roboshop && \
    chown -R roboshop:roboshop /opt/server
EXPOSE 8080
# this label content in maven style lo vundi
LABEL com.project="roboshop" \
      component="catalogue" \
      created_by="sivakumar"
ENV MONGO="true" \
    MONGO_URL="mongodb://mongodb:27017/catalogue"
    
# ikkada developer change cheste change avuthundhi so last rasam 
COPY --from=build --chown=roboshop:roboshop/opt/server /opt/server 


# these will not work in build time so ekkada pettina okkate
CMD ["server.js"]
ENTRYPOINT ["node"]

