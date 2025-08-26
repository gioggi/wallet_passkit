### Contribuire al progetto

Grazie per voler contribuire! Per mantenere il progetto ordinato e stabile, segui il flusso di lavoro qui sotto. Le regole sono semplici ma **obbligatorie**.

- **Prerequisiti**
  - Assicurati di avere un ambiente di sviluppo funzionante e di poter eseguire i test localmente.
  - Rispetta lo stile del codice esistente (lint, formattazione, convenzioni).

### Flusso di lavoro obbligatorio

1. **Apri una Issue**
   - Cerca prima se esiste già un'issue simile.
   - Se non esiste, aprine una descrivendo chiaramente: contesto, problema, proposta di soluzione e impatto.
2. **Crea un branch dedicato**
   - Usa un nome descrittivo, ad esempio: `feature/nome-breve` o `fix/bug-descrizione`.
3. **Apri una Pull Request (PR)**
   - Collega la PR all'Issue (usa parole chiave come "Closes #<numero>").
   - Spiega cosa cambia, perché, e come è stato testato.
   - Mantieni la PR piccola e focalizzata.
4. **Assicurati che i test passino**
   - Esegui i test in locale prima di inviare.
   - La CI deve risultare verde. PR con test rossi non verranno fuse.
5. **Revisione e merge**
   - Il maintainer rivede la PR e, se tutto è ok e i test passano, **approva e fa il merge**.
   - Potrebbe chiedere modifiche: rispondi puntualmente ai commenti e aggiorna la PR.

### Linee guida per commit e PR

- **Commit**
  - Messaggi chiari e descrittivi (imperativo, es.: "Aggiunge validazione email").
  - Unità logiche: evita commit monolitici con cambi non correlati.
- **PR**
  - Descrizione completa (cosa, perché, come testare).
  - Checklist suggerita:
    - [ ] Issue collegata
    - [ ] Test aggiornati/aggiunti
    - [ ] Lint/format eseguiti
    - [ ] Breaking changes documentate

### Eseguire i test

- Esegui tutti i test localmente prima di aprire/aggiornare la PR.
- Se esistono script nel progetto (es. `make test`, `npm test`, `pytest`, ecc.), usali.

### Domande

Se hai dubbi, apri una **Discussion** o chiedi chiarimenti nell'Issue prima di implementare.