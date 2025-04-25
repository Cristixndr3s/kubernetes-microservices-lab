# Ruta al JDK 17 (ajústala si es diferente en tu equipo)
$java17Path = "C:\Program Files\Java\jdk-17.0.14+7"

if (-Not (Test-Path $java17Path)) {
    Write-Host "❌ No se encontró Java 17 en: $java17Path"
    Write-Host "🧩 Por favor instala el JDK 17 desde: https://adoptium.net/"
    exit 1
}

# Establece las variables de entorno solo para esta sesión
$env:JAVA_HOME = $java17Path
$env:Path = "$env:JAVA_HOME\bin;" + $env:Path

# Verifica que se haya aplicado correctamente
Write-Host "`n✅ JAVA_HOME ahora apunta a:" $env:JAVA_HOME
java -version
