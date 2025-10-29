<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Laravel\Lumen\Routing\Controller as BaseController;

class QuoteController extends BaseController
{
    /** Verzeichnisse für Fortune-Datenbanken */
    private array $fortuneDirs = [
        '/usr/share/games/fortunes',
        '/usr/share/games/fortunes/de',
        '/usr/share/games/fortunes/local',
    ];

    /** Standardkategorie, falls keine gewählt */
    private string $defaultCategory = 'de/zitate';

    private function jsonResponse($success, $data = null, $error = null, $status = 200)
    {
        return response()->json([
            'success'   => $success,
            'timestamp' => date(DATE_ISO8601),
            $success ? 'data' : 'error' => $success ? $data : $error
        ], $status);
    }

    /** Alle verfügbaren Fortune-Dateien (ohne .dat/.u8) */
    private function getAllCategories(): array
    {
        $categories = [];
        foreach ($this->fortuneDirs as $dir) {
            if (!is_dir($dir)) continue;
            foreach (scandir($dir) as $file) {
                if (in_array($file, ['.', '..']) || preg_match('/\.(dat|u8)$/', $file)) continue;
                $path = "$dir/$file";
                if (is_file($path)) {
                    $rel = str_replace('/usr/share/games/fortunes/', '', $path);
                    $categories[] = $rel;
                }
            }
        }
        // deutsche zuerst
        usort($categories, fn($a,$b)=>str_starts_with($a,'de/')?-1:(str_starts_with($b,'de/')?1:strcmp($a,$b)));
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

    /** Alle verfügbaren Cowfiles */
    public function getCows()
    {
        $files = glob('/usr/share/cowsay/cows/*.cow');
        $names = array_map(fn($f)=>basename($f,'.cow'), $files);
        sort($names);
        return $this->jsonResponse(true, [
            'count' => count($names),
            'cows' => $names
        ]);
    }

    /** Hauptendpunkt: Fortune oder Cowsay ausgeben */
    public function getQuote(Request $request)
    {
        ob_start();
        try {
            $mode = strtolower($request->input('mode', 'cowsay'));
            $cat  = trim($request->input('cat', ''));
            $text = trim($request->input('text', ''));
            $cow  = trim($request->input('cow', 'default'));

            $validModes = ['fortunes', 'cowsay'];
            if (!in_array($mode, $validModes)) {
                return $this->jsonResponse(false, null, [
                    'message' => "Ungültiger Modus '$mode'. Erlaubt: 'fortunes' oder 'cowsay'.",
                    'code'    => 400
                ], 400);
            }

            $categories = $this->getAllCategories();
            if ($cat === '' || !in_array($cat, $categories)) {
                $cat = in_array($this->defaultCategory, $categories)
                    ? $this->defaultCategory
                    : ($categories[array_rand($categories)] ?? null);
            }

            $fortune = $text ?: trim(shell_exec("/usr/games/fortune " . escapeshellarg("/usr/share/games/fortunes/$cat") . " 2>/dev/null"));
            if ($fortune === '') $fortune = 'Keine Fortune-Einträge gefunden.';

            if ($mode === 'cowsay') {
                $cowParam = '';
                if ($cow !== 'default') {
                    $cowFile = "/usr/share/cowsay/cows/$cow.cow";
                    if (file_exists($cowFile)) {
                        $cowParam = "-f " . escapeshellarg($cow);
                    }
                }
                $fortune = trim(shell_exec("echo " . escapeshellarg($fortune) . " | /usr/games/cowsay $cowParam 2>/dev/null")) ?: $fortune;
            }

            return $this->jsonResponse(true, [
                'type'     => $mode,
                'category' => $cat,
                'cow'      => $cow,
                'output'   => $fortune
            ]);
        } finally {
            ob_end_clean();
        }
    }
}
