/**
 * Auto-label issues based on checkboxes in the body and clean up the body
 */
export async function processIssueLabelsAndBody({ github, context, core }) {
  const body = context.payload.issue.body;
  console.log('Issue body:', body);

  const labelsToAdd = [];
  let foundCheckboxesSection = false;
  let sectionToRemove = '';

  const scopeMap = {
    '🧱 Код': '🧱 Код',
    '🎨 Спрайты': '🎨 Спрайты',
    '🗺 Карты': '🗺 Маппинг'
  };

  if (body) {
    if (body.includes('Что потребует изменений?')) {
      foundCheckboxesSection = true;
      sectionToRemove = 'Что потребует изменений?';
      console.log('Found "Что потребует изменений?" section');
    } else if (body.includes('Категория бага')) {
      foundCheckboxesSection = true;
      sectionToRemove = 'Категория бага';
      console.log('Found "Категория бага" section');
    }

    if (body.includes('[x]')) {
      console.log('Found checked checkboxes in body');
      for (const [checkboxLabel, labelName] of Object.entries(scopeMap)) {
        const checkboxRegex = new RegExp('\\[x\\]\\s*' + checkboxLabel.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'));
        if (checkboxRegex.test(body)) {
          labelsToAdd.push(labelName);
          console.log('Found selected:', checkboxLabel, '->', labelName);
        }
      }
    }
  }

  const uniqueLabels = [...new Set(labelsToAdd)];
  console.log('Labels to add:', uniqueLabels);

  // If checkboxes section found but no labels added, add "Other"
  if (foundCheckboxesSection && uniqueLabels.length === 0) {
    uniqueLabels.push('🔸 Другое');
    console.log('No specific labels selected, adding "🔸 Другое"');
  }

  if (uniqueLabels.length > 0) {
    try {
      await github.rest.issues.addLabels({
        owner: context.repo.owner,
        repo: context.repo.repo,
        issue_number: context.issue.number,
        labels: uniqueLabels
      });
      console.log('Labels added successfully');
    } catch (error) {
      console.log('Error adding labels:', error);
    }
  }

  // Clean up body if section found
  if (foundCheckboxesSection) {
    console.log('Section to remove:', sectionToRemove);
    console.log('Original body:', body);

    if (!body || !sectionToRemove) {
      console.log('No body or section to clean');
      return;
    }

    let cleanedBody = body;

    const regex = new RegExp('###?\\s*' + sectionToRemove + '[\\s\\S]*?((?=###)|$)', 'i');
    cleanedBody = cleanedBody.replace(regex, '');
    cleanedBody = cleanedBody.replace(/-\s*\[[x\s]\]\s*.*\n/g, '');
    cleanedBody = cleanedBody.replace(/_No response_/g, '_Отсутствует_');
    cleanedBody = cleanedBody.replace(/\n{3,}/g, '\n\n');
    cleanedBody = cleanedBody.replace(/^###\s*$/gm, '');
    cleanedBody = cleanedBody.trim();

    console.log('Cleaned body:', cleanedBody);

    if (body !== cleanedBody && cleanedBody.length > 0) {
      try {
        await github.rest.issues.update({
          owner: context.repo.owner,
          repo: context.repo.repo,
          issue_number: context.issue.number,
          body: cleanedBody
        });
        console.log('Issue body cleaned successfully');
      } catch (error) {
        console.log('Error cleaning issue body:', error);
      }
    } else {
      console.log('No changes to body needed');
    }
  }

  core.setOutput('foundCheckboxesSection', foundCheckboxesSection);
  core.setOutput('sectionToRemove', sectionToRemove);

  return {
    foundCheckboxesSection: foundCheckboxesSection,
    sectionToRemove: sectionToRemove
  };
}
