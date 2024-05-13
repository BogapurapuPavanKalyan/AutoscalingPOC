# Set the SQS queue URL
$sqsQueueUrl = "https://sqs.us-east-1.amazonaws.com/619553686330/Robot-Test-Queue"
 
# Set the bucket name and file path for the report
$bucketName = "2112965-pavan"
# Set the folder name inside the bucket
$folderName = "DEMO-ROBOT"  # Specify the folder name
$reportFilePath = "report.html"  # Replace with the path to your report file
 
# Infinite loop to continuously process messages
while ($true) {
    # Receive the SQS message
    $queueMessage = Receive-SqsMessage -QueueUrl $sqsQueueUrl
 
    # Check if the $queueMessage variable is not null
    if ($queueMessage -ne $null) {
        # Remove the SQS message after processing
        Remove-SqsMessage -QueueUrl $sqsQueueUrl -ReceiptHandle $queueMessage.ReceiptHandle -Force
        # Get the test suite name from the message body
        $testSuiteName = $queueMessage.Body
 
        # Execute the Robot Framework tests
        Start-Process -FilePath "robot" -ArgumentList "$testSuiteName" -NoNewWindow -Wait
        # Generate timestamp
        $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
        # Set the report key name with timestamp and folder
        $reportKeyName = "$folderName/report_$timestamp.html"  # Key name for the report in S3
        # Copy the report to S3 after test execution
        Write-S3Object -BucketName $bucketName -File $reportFilePath -Key $reportKeyName
    }
}
