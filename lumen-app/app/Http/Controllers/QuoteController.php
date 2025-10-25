<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Laravel\Lumen\Routing\Controller as BaseController;

class QuoteController extends BaseController
{
    private array $fortuneDirs = [
        '/usr/share/games/fortunes',
        '/usr/share/games/fortunes/de',
        '/usr/share/games/fortunes/local',
    ];

    private function jsonResponse($success, $data = null, $error = null, $status = 200)
    {
        return response()->json([
            'success'   => $success,
            'timestamp' => date(DATE_ISO8601),
            $success ? 'data' : 'error' => $success ? $data : $error
        ], $status);
    }

    /** Alle verfügbaren Fortune-Dateien (ohne .dat/.u8) sammeln */
    private function getAllCategories(): array
    {
        $categories = [];
        foreach ($this->fortuneDirs as $dir) {
            if (!is_dir($dir)) continue;
            $files = scandir($dir);
            foreach ($files as $file) {
                if (in_array($file, ['.', '..'])) continue;
                if (preg_match('/\.(dat|u8)$/', $file)) continue;
                $path = "$dir/$file";
                if (is_file($path)) {
                    // Beispiel: /usr/share/games/fortunes/de/zitate → de/zitate
                    $rel = str_replace('/usr/share/games/fortunes/', '', $path);
                    $categories[] = $rel;
                }
            }
        }
        sort($categories);
        return array_values(array_unique($categories));
    }

    public function getCategories()
    {
        $cats = $this->getAllCategories();
        return $this->jsonResponse(true, [
            'count' => count($cats),
            'categories' => $cats
        ]);
    }

    public function getQuote(Request $request)
    {
        ob_start();
        try {
            $mode = strtolower($request->input('mode', 'cowsay'));
            $cat  = trim($request->input('cat', ''));

            $validModes = ['fortunes', 'cowsay'];
            if (!in_array($mode, $validModes)) {
                return $this->jsonResponse(false, null, [
                    'message' => "Ungültiger Modus '$mode'. Erlaubt: 'fortunes' oder 'cowsay'.",
                    'code'    => 400
                ], 400);
            }

            $categories = $this->getAllCategories();

            // Falls Kategorie fehlt oder ungültig → zufällige wählen
            if ($cat === '' || !in_array($cat, $categories)) {
                $cat = $categories[array_rand($categories)] ?? null;
                if (!$cat) {
                    return $this->jsonResponse(false, null, [
                        'message' => "Keine Fortune-Datenbanken gefunden.",
                        'code'    => 404
                    ], 404);
                }
            }

            $fortune = trim(shell_exec('fortune ' . escapeshellarg("/usr/share/games/fortunes/$cat") . ' 2>/dev/null'));
            if ($fortune === '') $fortune = 'Keine Fortune-Einträge gefunden.';

            if ($mode === 'cowsay') {
                $fortune = trim(shell_exec('echo ' . escapeshellarg($fortune) . ' | cowsay 2>/dev/null'));
            }

            return $this->jsonResponse(true, [
                'type'     => $mode,
                'category' => $cat,
                'output'   => $fortune
            ]);
        } finally {
            ob_end_clean();
        }
    }
}
