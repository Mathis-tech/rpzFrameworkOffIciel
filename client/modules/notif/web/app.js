window.addEventListener('message', function(event) {
    const data = event.data;
    document.getElementById('title').textContent = data.title;
    document.getElementById('subtitle').textContent = data.subtitle;
    document.getElementById('text').textContent = data.text;
    document.getElementById('notification').style.display = 'block';
    // setTimeout(() => {
    //     document.getElementById('notification').style.display = 'none';
    // }, 5000); // La notification disparaît après 5 secondes
});
