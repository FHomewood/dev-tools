### © Copyright 2024 Frankie Homewood <F.Homewood@outlook.com>
# A prompt script to contain the prompt function to be sourced alone.

function prompt {
    $folder_name = Split-Path -Path (Get-Location) -Leaf
    
    $prompt = ""
    switch ($true) {
        ([boolean]$VIRTUAL_ENV_PATH) { 
            $prompt += "$([char]27)[38;5;150m$(Split-Path -Path $VIRTUAL_ENV_PATH -Leaf)$([char]27)[38;5;249m:" 
        }
        Default { 
            $prompt += "$([char]27)[38;5;150mwindows$([char]27)[38;5;249m:" 
        }
    }
    $prompt += "$([char]27)[38;5;141m$folder_name$([char]27)[38;5;249m > $([char]27)[39m"
    return $prompt
}