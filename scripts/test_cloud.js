(async () => {
  const formData = new FormData();
  formData.append('upload_preset', 'atlas_preset');
  formData.append('file', 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=');

  try {
    const res = await fetch('https://api.cloudinary.com/v1_1/uxqne9dx/image/upload', {
      method: 'POST',
      body: formData
    });
    console.log('Status:', res.status);
    console.log('Response:', await res.text());
  } catch(e) {
    console.error(e);
  }
})();
