# Use Node.js 16 LTS as required
FROM node:16-alpine

# Create app directory
WORKDIR /app

# Install app dependencies
COPY package*.json ./
RUN npm ci --omit=dev || npm install --save

# Bundle app source
COPY . .

# Expose app port
EXPOSE 8080

# Run the application
CMD ["npm", "start"]
