using System;
using System.Diagnostics;
using System.IO;
using System.Windows.Forms;

internal static class ErxckOS
{
    [STAThread]
    private static int Main(string[] args)
    {
        string root = AppDomain.CurrentDomain.BaseDirectory;
        bool check = args.Length == 1 && args[0] == "--self-test";
        if (args.Length != 0 && !check) return 64;
        string[] required = {
            "ErxckOS.ps1", "update-config.json", "Assets/ErxckOS.ico",
            "Assets/logo.png", "Assets/wallpaper.png", "Scripts/Invoke-ErxckOS.ps1",
            "Scripts/ErxckOS.Power.ps1", "Scripts/ErxckOS.Elevate.exe"
        };
        foreach (string file in required)
        {
            if (!File.Exists(Path.Combine(root, file)))
            {
                if (!check) MessageBox.Show("Falta un archivo de ErxckOS Tool: " + file +
                    "\nVuelve a instalar la aplicacion.", "ErxckOS", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return 2;
            }
        }
        // Diagnostics never starts PowerShell, the UI, or any tweak.
        if (check) return 0;
        try
        {
            string powershell = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.System),
                @"WindowsPowerShell\v1.0\powershell.exe");
            var start = new ProcessStartInfo(powershell,
                "-NoProfile -ExecutionPolicy Bypass -STA -File \"" + Path.Combine(root, "ErxckOS.ps1") + "\"");
            start.WorkingDirectory = root;
            start.UseShellExecute = false;
            start.CreateNoWindow = true;
            using (Process process = Process.Start(start))
            {
                process.WaitForExit();
                return process.ExitCode;
            }
        }
        catch (Exception error)
        {
            MessageBox.Show("No se pudo abrir ErxckOS Tool.\n" + error.Message,
                "ErxckOS", MessageBoxButtons.OK, MessageBoxIcon.Error);
            return 1;
        }
    }
}
