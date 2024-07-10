document.addEventListener('DOMContentLoaded', () => {
    const searchInput = document.querySelector('.search-area input');
  
    searchInput.addEventListener('input', (e) => {
      const searchTerm = e.target.value.toLowerCase();
      const items = document.querySelectorAll('.inventory-grid .item');
  
      items.forEach(item => {
        const itemName = item.querySelector('span').textContent.toLowerCase();
        if (itemName.includes(searchTerm)) {
          item.style.display = 'block';
        } else {
          item.style.display = 'none';
        }
      });
    });

    const filterIcons = document.querySelectorAll('.filter-icons i');
  
    filterIcons.forEach(icon => {
      icon.addEventListener('click', function() {
        const filterType = this.classList[1]; // récupère la classe spécifique de l'icône cliquée
        console.log('Filtrer l’inventaire pour:', filterType);
        // Ici, vous implémenterez la logique de filtrage de l'inventaire en fonction de l'icône cliquée
      });
    });

    const inventoryGrid = document.querySelector('.inventory-grid');
    const numberOfSlots = 32; // ou le nombre que vous voulez
  
    for (let i = 0; i < numberOfSlots; i++) {
      const slot = document.createElement('div');
      slot.className = 'inventory-slot';
      inventoryGrid.appendChild(slot);
    }

    function updateSlotCount() {
        const occupiedSlots = document.querySelectorAll('.inventory-slot.occupied').length;
        const slotCountElement = document.querySelector('.slot-count');
        slotCountElement.textContent = `${occupiedSlots}/32`;
      }

      updateSlotCount();
  });
  

  