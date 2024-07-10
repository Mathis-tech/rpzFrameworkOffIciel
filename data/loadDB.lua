-- Load the list of banned words
local bannedWords = {}
local stockRandom = {}
local jobs = {}
local defaultJob = {}
local staff = {}

function loadJobs()
    local content = LoadResourceFile(GetCurrentResourceName(), "data/jobs.json")
    local jobsCount = 0
    local gradesCount = 0

    if content then
        local status, result = pcall(json.decode, content)
        if status then
            if result[1] then
                -- Chargement des emplois réguliers
                if result[1].jobs then
                    jobs = result[1].jobs
                    jobsCount = #jobs -- Compter le nombre d'emplois
                    for _, job in ipairs(jobs) do
                        gradesCount = gradesCount + #job.grades -- Compter le total des grades pour tous les emplois
                    end
                 --   print("Emploi chargé : " .. jobsCount)
                --    print("Grade chargé : " .. gradesCount)
                    print("Fichier des emplois avec grades chargé avec succès.")
                else
                    print("Erreur: Le fichier JSON n'a pas de clé 'jobs' ou elle est définie à null.")
                end

                -- Chargement de l'emploi par défaut
                if result[1].jobsDefault then
                    defaultJob = result[1].jobsDefault[1] -- Supposons que le job par défaut est toujours le premier élément
                    print("Emploi par défaut chargé : " .. defaultJob.label)
                else
                    print("Erreur: Le fichier JSON n'a pas de clé 'jobsDefault' ou elle est définie à null.")
                end
            else
                print("Erreur: Le fichier JSON principal ne contient pas de tableau au premier indice.")
            end
        else
            print("Erreur: Impossible de décoder le fichier des emplois. Détail de l'erreur JSON:", result)
        end
    else
        print("Erreur: Impossible de lire le fichier des emplois.")
    end
end

function loadBannedWords()
    local content = LoadResourceFile(GetCurrentResourceName(), "data/banned_words.json")
    if content then
        local status, result = pcall(json.decode, content)
        if status then
            if result[1] and result[1].banned_words then
                bannedWords = result[1].banned_words
                print("Fichier des mots interdits chargé avec succès.")
            --    print("Contenu de la liste des mots interdits:", json.encode(bannedWords))
            else
                print("Le fichier JSON n'a pas de clé 'banned_words' au premier élément ou elle est définie à null.")
            end
        else
            print("Erreur: Impossible de décoder le fichier des mots interdits. Contenu:", content)
            print("Détail de l'erreur JSON:", result)
        end
    else
        print("Erreur: Impossible de lire le fichier des mots interdits.")
    end
end

function loadstaff()
    local content = LoadResourceFile(GetCurrentResourceName(), "data/staff.json")
    if content then
        local status, result = pcall(json.decode, content)
        if status then
            if result and result[1] and result[1].staff then  -- Accédez d'abord à l'élément du tableau puis à la clé 'staff'
                staff = result[1].staff
                print("Fichier de la liste des staffs chargé avec succès.")
                --print("Contenu de la liste des staffs:", json.encode(staff))
            else
                print("Le fichier JSON n'a pas de clé 'staff' correctement placée ou elle est définie à null.")
            end
        else
            print("Erreur: Impossible de décoder le fichier de la liste des staffs. Détail de l'erreur JSON:", result)
        end
    else
        print("Erreur: Impossible de lire le fichier de la liste des staffs.")
    end
end


function loadStockRandom()
    local content = LoadResourceFile(GetCurrentResourceName(), "data/stockage_random.json")
    if content then
        stockRandom = json.decode(content).stockage_random
        print("Fichier stockage aléatoire chargé avec succès.")
    else
        print("Erreur: Impossible de lire le fichier des mots interdits.")
    end
end

loadBannedWords()
loadStockRandom()
loadJobs()
loadstaff()

function containsBannedWord(str)
    for _, word in ipairs(bannedWords) do
        if string.find(string.lower(str), string.lower(word)) then
            return true
        end
    end
    return false
end
