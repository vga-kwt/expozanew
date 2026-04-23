<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MyFatoorah API Key Test</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 p-8">
    <div class="max-w-2xl mx-auto bg-white rounded-lg shadow-lg p-6">
        <h1 class="text-2xl font-bold mb-4">MyFatoorah API Key Test</h1>
        
        <div class="mb-4 p-4 bg-blue-50 border border-blue-200 rounded">
            <p class="text-sm text-blue-800">
                <strong>Current Config:</strong><br>
                Mode: <span id="current-mode">{{ config('myfatoorah.test_mode') ? 'Test' : 'Live' }}</span><br>
                Country: {{ config('myfatoorah.country_iso') }}<br>
                API Key: <span id="current-key">{{ config('myfatoorah.api_key') ? substr(config('myfatoorah.api_key'), 0, 30) . '...' : 'Not Set' }}</span>
            </p>
        </div>

        <form id="testForm" class="space-y-4">
            <div>
                <label class="block text-sm font-medium mb-2">Test API Key (Optional - leave empty to use config key):</label>
                <input type="text" id="apiKey" name="api_key" 
                       placeholder="Enter API key to test (or leave empty to test current config)"
                       class="w-full px-4 py-2 border rounded-md">
            </div>
            
            <button type="submit" 
                    class="w-full bg-blue-600 text-white py-2 px-4 rounded-md hover:bg-blue-700">
                Test API Key
            </button>
        </form>

        <div id="result" class="mt-4 hidden"></div>
    </div>

    <script>
        document.getElementById('testForm').addEventListener('submit', async (e) => {
            e.preventDefault();
            const apiKey = document.getElementById('apiKey').value;
            const resultDiv = document.getElementById('result');
            resultDiv.classList.remove('hidden');
            resultDiv.innerHTML = '<p class="text-blue-600">Testing...</p>';

            try {
                const response = await fetch('/test-myfatoorah-key', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRF-TOKEN': '{{ csrf_token() }}'
                    },
                    body: JSON.stringify({ api_key: apiKey || null })
                });

                const data = await response.json();
                
                if (data.success) {
                    resultDiv.innerHTML = `
                        <div class="p-4 bg-green-50 border border-green-200 rounded">
                            <p class="text-green-800 font-bold">✅ ${data.message}</p>
                            ${data.invoice_url ? `<p class="mt-2"><a href="${data.invoice_url}" target="_blank" class="text-blue-600 underline">View Invoice</a></p>` : ''}
                        </div>
                    `;
                } else {
                    let instructions = '';
                    if (data.instructions) {
                        instructions = '<ul class="list-disc list-inside mt-2">' + 
                            data.instructions.map(inst => `<li class="text-sm">${inst}</li>`).join('') + 
                            '</ul>';
                    }
                    resultDiv.innerHTML = `
                        <div class="p-4 bg-red-50 border border-red-200 rounded">
                            <p class="text-red-800 font-bold">❌ ${data.message}</p>
                            ${instructions}
                        </div>
                    `;
                }
            } catch (error) {
                resultDiv.innerHTML = `
                    <div class="p-4 bg-red-50 border border-red-200 rounded">
                        <p class="text-red-800">Error: ${error.message}</p>
                    </div>
                `;
            }
        });
    </script>
</body>
</html>

