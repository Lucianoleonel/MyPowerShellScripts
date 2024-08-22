using System;
using System.Security;
using System.Security.Cryptography;
using System.Runtime.InteropServices;
using System.Text;

namespace SecureStringToEncryptedString
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.Write("Ingrese la clave: ");
            SecureString securePassword = GetSecureStringFromConsoleInput();
            string encryptedPassword = ConvertSecureStringToEncryptedString(securePassword);
            Console.WriteLine($"Contraseña cifrada para RDP: {encryptedPassword}");
        }

        static SecureString GetSecureStringFromConsoleInput()
        {
            SecureString secureString = new SecureString();
            while (true)
            {
                ConsoleKeyInfo keyInfo = Console.ReadKey(intercept: true);
                if (keyInfo.Key == ConsoleKey.Enter)
                {
                    Console.WriteLine();
                    break;
                }
                else if (keyInfo.Key == ConsoleKey.Backspace)
                {
                    if (secureString.Length > 0)
                    {
                        secureString.RemoveAt(secureString.Length - 1);
                        Console.Write("\b \b");
                    }
                }
                else
                {
                    secureString.AppendChar(keyInfo.KeyChar);
                    Console.Write('*');
                }
            }
            secureString.MakeReadOnly();
            return secureString;
        }

        static string ConvertSecureStringToEncryptedString(SecureString secureString)
        {
            IntPtr unmanagedString = IntPtr.Zero;
            try
            {
                unmanagedString = Marshal.SecureStringToGlobalAllocUnicode(secureString);
                byte[] unmanagedBytes = Encoding.Unicode.GetBytes(Marshal.PtrToStringUni(unmanagedString));
                byte[] encryptedBytes = ProtectedData.Protect(unmanagedBytes, null, DataProtectionScope.CurrentUser);
                return BitConverter.ToString(encryptedBytes).Replace("-", "");
            }
            finally
            {
                if (unmanagedString != IntPtr.Zero)
                {
                    Marshal.ZeroFreeGlobalAllocUnicode(unmanagedString);
                }
            }
        }
    }
}
