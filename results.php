<!-- Dylan Vaughn -->

<html>
<style>
    /* <?php
    $image = "image.png"
    ?> */
    body {
        background-image: url('<?php echo $image;?>');
        background-repeat: no-repeat;
        background-attachment: fixed;
        background-size: 100% 100%;
        background-position: center; 
        text-align:center
    }

    form {
        text-align: center;
    }
</style>
<body>


<h3 style="color:rgb(0,0,0)">Enter your Query:</h3>
<form style="color:rgb(0,0,0)" action="results.php" method="post">
    <input type="text" name="query"><br>
    <input name="submit" type="submit" >
</form>
<br>

<?php
ini_set('display_errors', 1);
error_reporting(E_ALL);
if (isset($_POST['submit'])) 
{
    // add ' ' around multiple strings so they are treated as single command line args
    $query = escapeshellarg($_POST['query']);

    $data = http_build_query(['query' => $query]);
    $options = [
        'http' => [
            'header' => "Content-type: application/x-www-form-urlencoded\r\n",
            'method' => 'POST',
            'content' => $data,
        ],
    ];

    $context = stream_context_create($options);

    $targetUrl = 'http://www.csce.uark.edu/~dpvaughn/Homework4/input.html';

    $localFile = '/home/dpvaughn/public_html/Homework4/input.html';

    $tempFilePath = tempnam(sys_get_temp_dir(), 'tmp_');
    //echo $tempFilePath;
    //echo '<br>';
    //echo 'Current working directory: ' . getcwd();
    //echo '<br>';

    //unset($tempFilePath);

    file_put_contents($tempFilePath, $query);

    $response = file_get_contents($tempFilePath, false, $context);

    // build the linux command that you want executed;  
    $command = 'flex retrieve.flex';
    $command = escapeshellcmd($command);

    //echo "<p> command: $command <br>";
    system($command);     

    $command = 'g++ -o retrieve lex.yy.c hashtable.cpp -lfl';
    $command = escapeshellcmd($command);

    //echo "<p> command: $command <br>";
    system($command);

    $command = './retrieve ' . $tempFilePath . ' ' . $query;
    $command = escapeshellcmd($command);

    //echo "<p> command: $command <br>";
    $output = shell_exec("$command 2>&1"); 
        
    $separate_lines = explode("doc", $output);

    foreach ($separate_lines as $single_line) {
        $single_line = trim($single_line);

        if ($single_line === "") {
            continue;
        }

        $parts = explode(" ", $single_line, 3);

        if (count($parts) >= 3) {
            $doc_name = $parts[1];
            $score = $parts[2];
            $link = 'http://www.csce.uark.edu/~sgauch/5533/files/' . $doc_name;

            if ($doc_name != "No") {
                echo '<a href="' . $link . '">' . $doc_name . '</a> ' . $score;
            }
            else {
                echo $doc_name . " " . $score;
            }
            echo '<br>';
        }
        else {
            echo "Invalide line format: $single_line" . PHP_EOL;
        }
        
    }
        
    //echo "<p> C++ Program Output:$separate_lines<br<"; 
}
?>

<script>
         function query(){
            
         }
      </script>
<br><br>

</body>
</html>



