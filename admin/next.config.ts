import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  cacheComponents: true,
  partialPrefetching: true,
  async rewrites() {
   // const apiOrigin = process.env.API_PROXY_TARGET ?? "http://127.0.0.1:8000";
   const apiOrigin = "https://academyapp-ddfwe3asf7dyhqgn.southindia-01.azurewebsites.net";
    return [
      {
        source: "/api/:path*",
        destination: `${apiOrigin}/api/:path*`,
      },
    ];
  },
  turbopack: {
    rules: {
      "*.css": {
        loaders: ["@tailwindcss/turbopack"],
        as: "*.css",
      },
    },
  },
};

export default nextConfig;
