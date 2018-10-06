# by default, we'll create 10 new passwords
$numberOfPasswords = 10

# allowed characters
$characters = "abcdefghiklmnoprstuvwxyzABCDEFGHKLMNOPRSTUVWXYZ1234567890!$%&/()=?}][{@#*+"
function Get-RandomPassword($length) { 
    $random = 1..$length | ForEach-Object { Get-Random -Maximum $characters.length } 
    # define the output field separator, could be a letter or number or empty space
    $private:ofs=""
    return [String]$characters[$random]
}

# loop (n) number of times
1..$numberOfPasswords | % {
    $password = Get-RandomPassword(15)
    $output = 'Random Password is: {0}' -f $password
    Write-Output $output
}
