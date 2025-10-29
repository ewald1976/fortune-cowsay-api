<?php

/** @var \Laravel\Lumen\Routing\Router $router */

/*
|--------------------------------------------------------------------------
| Application Routes
|--------------------------------------------------------------------------
|
| Here is where you can register all of the routes for an application.
| It is a breeze. Simply tell Lumen the URIs it should respond to
| and give it the Closure to call when that URI is requested.
|
*/
$router->get('/', fn() => response()->json(['message' => 'Fortune API läuft 🚀']));
$router->post('/api/quote', 'QuoteController@getQuote');
$router->get('/api/categories', 'QuoteController@getCategories');
$router->get('/api/health', function () {
    $fortune = trim(shell_exec('which fortune 2>/dev/null')) !== '';
    $cowsay  = trim(shell_exec('which cowsay 2>/dev/null')) !== '';

    return response()->json([
        'status'  => 'ok',
        'fortune' => $fortune ? 'available' : 'missing',
        'cowsay'  => $cowsay  ? 'available' : 'missing',
        'time'    => date(DATE_ISO8601)
    ]);
$router->get('/api/categories', 'QuoteController@getCategories');
$router->get('/api/cows', 'QuoteController@getCows');
$router->post('/api/quote', 'QuoteController@getQuote');

});
