<!-- Dylan Vaughn -->

<html>
<style>
    <?php
    $image = "image.png"
    ?>
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
<?php
if (isset($_POST['submit'])) 
{
    // add ' ' around multiple strings so they are treated as single command line args
    $query = escapeshellarg($_POST[query]);

    $tempFilePath = tempnam(sys_get_temp_dir(), 'tmp_');

    file_put_contents($tempFilePath, $query);

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
    $output = shell_exec($command); 
    $separate_lines = explode("doc", $output);

    foreach ($separate_lines as $single_line) {
        $single_line = trim($single_line);

        if ($single_line === "") {
            continue;
        }

        $parts = explode(" ", $single_line, 3);

        $doc_name = $parts[1];
        $score = $parts[2];

        echo $doc_name . " " . $score . PHP_EOL;
    }
        
    //echo "<p> C++ Program Output:$separate_lines<br<";
}

?>

<h3 style="color:rgb(0,0,0)">Enter your Query:</h3>
<form style="color:rgb(0,0,0)" action="results.php" method="post">
    <input type="text" name="query"><br>
    <input name="submit" type="submit" >
</form>
<br><br>

<script>
         function query(){
            
         }
      </script>
<br><br>

</body>
</html>



