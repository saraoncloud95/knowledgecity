function handler(event) {
    var request = event.request;
    var uri = request.uri;
    
    // Add security headers
    var response = {
        statusCode: 200,
        statusDescription: 'OK',
        headers: {
            'x-content-type-options': { value: 'nosniff' },
            'x-frame-options': { value: 'SAMEORIGIN' },
            'x-xss-protection': { value: '1; mode=block' },
            'referrer-policy': { value: 'strict-origin-when-cross-origin' },
            'permissions-policy': { value: 'geolocation=(), microphone=(), camera=()' }
        }
    };
    
    // Handle SPA routing - redirect all requests to index.html except for static assets
    if (!uri.includes('.') && !uri.startsWith('/api/')) {
        request.uri = '/index.html';
    }
    
    // Add cache control headers for static assets
    if (uri.match(/\.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$/)) {
        response.headers['cache-control'] = { value: 'public, max-age=31536000, immutable' };
    }
    
    // Add cache control headers for video content
    if (uri.match(/\.(mp4|webm|ogg|m4v|mov)$/)) {
        response.headers['cache-control'] = { value: 'public, max-age=86400' };
    }
    
    return request;
} 