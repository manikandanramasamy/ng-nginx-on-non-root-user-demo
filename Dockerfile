# Step 1: Build the Angular app
FROM node:latest AS build

# Set the working directory
WORKDIR /app

# Copy package.json and install dependencies
COPY package*.json ./
RUN npm install 

# Copy source files into the container
COPY . .

# Build the Angular app for production
RUN npm run build  --configuration=production


FROM nginx:1.20

# Define build arguments for user and group
ARG USERNAME=myuser
ARG GROUPNAME=mygroup

# Create a custom user and group (replace with build args)
RUN addgroup --system ${GROUPNAME} && \
    adduser --system --no-create-home --disabled-login --ingroup ${GROUPNAME} ${USERNAME}


# Copy custom nginx configuration and index page
# Copy custom Nginx configuration and HTML files
COPY nginx.conf /etc/nginx/nginx.conf
#COPY html/  /etc/nginx/html/   

# Copy built app to the default web server directory
COPY --from=build /app/dist/ng-nginx-on-non-root-user-demo /etc/nginx/html/  


# Working directory if needed for application files
# If no application files are going into /app, you might not need this
#WORKDIR /app

# Change ownership and permissions to the new user and group
RUN chown -R ${USERNAME}:${GROUPNAME} /etc/nginx/html /var/cache/nginx /var/log/nginx /etc/nginx/conf.d

# Set the correct permissions for the pid file
RUN touch /var/run/nginx.pid && \
        chown ${USERNAME}:${GROUPNAME} /var/run/nginx.pid

# Switch to the new user
USER ${USERNAME}

# Expose port 80 for HTTP
EXPOSE 80

# Start Nginx in the foreground
ENTRYPOINT ["nginx", "-g", "daemon off;"]
