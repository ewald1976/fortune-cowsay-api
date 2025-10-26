<?php

namespace App\Http\Middleware;

use Closure;

class CorsMiddleware
{
    public function handle($request, Closure $next)
    {
        // Wenn Preflight-Anfrage → direkt mit 204 antworten
        if ($request->getMethod() === "OPTIONS") {
            return response('', 204)
                ->header('Access-Control-Allow-Origin', '*')
                ->header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
                ->header('Access-Control-Allow-Headers', 'Origin, Content-Type, Accept, Authorization');
        }

        // Normale Anfrage → Response dekorieren
        $response = $next($request);
        return $response
            ->header('Access-Control-Allow-Origin', '*')
            ->header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
            ->header('Access-Control-Allow-Headers', 'Origin, Content-Type, Accept, Authorization');
    }
}
