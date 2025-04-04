<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Info</title>
    <style>
        body {
            background-color: white;
            text-align: center;
            margin: 0;
            padding: 0;
            overflow-x: hidden;
        }
        .container {
            display: flex;
            flex-wrap: wrap;
            justify-content: center;
            gap: 20px;
            padding: 20px;
            max-width: 100vw;
        }
        .box {
            border: 3px solid #000;
            padding: 10px;
            background-color: white;
            width: 200px;
            text-align: center;
            border-radius: 10px;
        }
        .photo {
            width: 200px;
            height: 250px;
            object-fit: cover;
            border-radius: 10px;
            border: none;
        }
        .input-container {
            margin: 20px;
        }
        input {
            padding: 10px;
            font-size: 16px;
            text-transform: uppercase;
        }
        .btn {
            padding: 12px 24px;
            font-size: 16px;
            font-weight: 600;
            color: #fff;
            background: linear-gradient(135deg, #FFA500, #FF8C00);
            border: none;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.3s ease-in-out;
            text-transform: uppercase;
        }
        .btn:hover {
            background: linear-gradient(135deg, #FF8C00, #FFA500);
        }
        .btn:active {
            transform: translateY(1px);
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.2);
        }

        .loader {
            display: none;
            justify-content: space-between;
            width: 80px;
            margin: 20px auto;
        }
        .loader div {
            width: 16px;
            height: 16px;
            background-color: orange;
            border-radius: 50%;
            animation: bounce 1.5s infinite ease-in-out;
        }
        .loader div:nth-child(1) { animation-delay: 0s; }
        .loader div:nth-child(2) { animation-delay: 0.2s; }
        .loader div:nth-child(3) { animation-delay: 0.4s; }

        @keyframes bounce {
            0%, 80%, 100% { transform: scale(0); opacity: 0.3; }
            40% { transform: scale(1); opacity: 1; }
        }

        .pagination {
            margin-top: 20px;
        }
        .pagination button {
            padding: 10px 20px;
            font-size: 16px;
            margin: 5px;
            cursor: pointer;
            border: 2px solid #ff9800;
            background: white;
            color: #ff9800;
            border-radius: 5px;
            transition: all 0.3s;
        }
        .pagination button:hover {
            background: #ff9800;
            color: white;
        }
    </style>
</head>
<body>
    <img style="height: 120px; width: 100%; max-width: 1100px;" src="https://examsection.acet.ac.in/Images/header.jpg">
    <hr>
    <h3>STUDENT PHOTOS</h3>
    <p>Enter Roll Number Prefix (e.g., 23MH1A49) to generate student photos.</p>
    <div class="input-container">
        <input type="text" id="rollNumberInput" placeholder="Enter Roll Number Prefix" onkeypress="handleKeyPress(event)">
        <button class="btn" onclick="generatePhotos()">Generate Photos</button>
    </div>
    <div class="loader" id="loader">
        <div></div>
        <div></div>
        <div></div>
    </div>
    <div class="container" id="photoContainer"></div>
    <div class="pagination" id="pagination"></div>

    <marquee style="background-color: orange; height: 30px;">Thank you for visiting our page! We hope you find it useful and informative.</marquee>
    <p>"Now displaying both Regular & Lateral Entry (LE) student photos!"</p>

    <script>
        let validImages = [];
        let currentPage = 0;
        const imagesPerPage = 100;

        function checkImageExists(url) {
            return new Promise((resolve) => {
                let img = new Image();
                img.src = url;
                img.onload = () => resolve(url);
                img.onerror = () => resolve(null);
            });
        }

        async function generatePhotos() {
            var prefix = document.getElementById("rollNumberInput").value.trim().toUpperCase();
            var container = document.getElementById("photoContainer");
            var pagination = document.getElementById("pagination");

            container.innerHTML = "";
            pagination.innerHTML = "";

            if (prefix.length === 10) {
                let imageUrl = `https://info.aec.edu.in/acet/studentPhotos/${prefix}.jpg`;
                
                if (prefix.substring(2,4) === "A9") {
                    imageUrl = `https://info.aec.edu.in/AEC/studentPhotos/${prefix}.jpg`;
                }

                let exists = await checkImageExists(imageUrl);
                if (!exists) {
                    alert("Photo not found.");
                    return;
                }

                container.innerHTML = `<div class="box"><h4>${prefix}</h4><img class="photo" src="${imageUrl}" alt="Student Photo"></div>`;
                return;
            }

            if (prefix.length !== 8) {
                alert("Please enter a valid roll number prefix (e.g., 23MH1A49).");
                return;
            }
        
            loader.style.display = "flex";

            let rollNumbers = [];
            rollNumbers.push(...generateRollNumbers(prefix));
            var lePrefix = convertToLE(prefix);
            rollNumbers.push(...generateRollNumbers(lePrefix));

            let results = await Promise.allSettled(
                rollNumbers.map(roll => {
                    let url = `https://info.aec.edu.in/acet/studentPhotos/${roll}.jpg`;

                    if (prefix.substring(2,4) === "A9") {
                        url = `https://info.aec.edu.in/AEC/studentPhotos/${roll}.jpg`;
                    }

                    return checkImageExists(url).then(result => (result ? { roll, imageUrl: url } : null));
                })
            );

            validImages = results.filter(result => result.status === "fulfilled" && result.value !== null).map(result => result.value);

            loader.style.display = "none";
            
            if (validImages.length === 0) {
                container.innerHTML = "<p>No photos found.</p>";
                return;
            }

            currentPage = 0;
            displayPhotos();
        }

        function displayPhotos() {
            var container = document.getElementById("photoContainer");
            var pagination = document.getElementById("pagination");
            container.innerHTML = "";
            pagination.innerHTML = "";

            let start = currentPage * imagesPerPage;
            let end = start + imagesPerPage;
            let imagesToShow = validImages.slice(start, end);

            let fragment = document.createDocumentFragment();
            imagesToShow.forEach(({ roll, imageUrl }) => {
                var box = document.createElement("div");
                box.classList.add("box");
                box.innerHTML = `<h4>${roll}</h4><img class="photo" src="${imageUrl}" alt="Student Photo">`;
                fragment.appendChild(box);
            });
            container.appendChild(fragment);
        }

        function handleKeyPress(event) {
            if (event.key === "Enter") {
                generatePhotos();
            }
        }
    </script>
</body>
</html>
