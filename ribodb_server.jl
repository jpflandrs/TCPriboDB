
using Sockets
using Serialization
using Dates
using Random

include("Module_moteur_serveur.jl")
include("Module_bnf.jl")

using .Module_moteur_serveur, .Module_bnf

"""
ribodb_server.jl Le serveur TCP de riboDB

Copyright or © or Copr. UCBL Lyon, France;  
contributor : [Jean-Pierre Flandrois] ([2024/12/20])
[JP.flandrois@univ-lyon1.fr]

This software is a computer program whose purpose is to create a TCP server interface to the riboDB sequence database.

This software is governed by the [CeCILL|CeCILL-B|CeCILL-C] license under French law and
abiding by the rules of distribution of free software.  You can  use, 
modify and/ or redistribute the software under the terms of the [CeCILL|CeCILL-B|CeCILL-C]
license as circulated by CEA, CNRS and INRIA at the following URL
"http://www.cecill.info". 

As a counterpart to the access to the source code and  rights to copy,
modify and redistribute granted by the license, users are provided only
with a limited warranty  and the software's author,  the holder of the
economic rights,  and the successive licensors  have only  limited
liability. 

In this respect, the user's attention is drawn to the risks associated
with loading,  using,  modifying and/or developing or reproducing the
software by the user in light of its specific status of free software,
that may mean  that it is complicated to manipulate,  and  that  also
therefore means  that it is reserved for developers  and  experienced
professionals having in-depth computer knowledge. Users are therefore
encouraged to load and test the software's suitability as regards their
requirements in conditions enabling the security of their systems and/or 
data to be ensured and,  more generally, to use and operate it in the 
same conditions as regards security. 

The fact that you are presently reading this means that you have had
knowledge of the [CeCILL|CeCILL-B|CeCILL-C] license and that you accept its terms.

"""


function uniqueutilisateurserveur(suffixeperso::String)
    #println(pwd())
    fichtempo::String =  joinpath("public","utilisateurs","task_"*suffixeperso)
    println("tempo $fichtempo")
    if ispath(fichtempo) ==0
        mkdir(fichtempo)
        println("tempocree $fichtempo")
    end
    
    atelier::String=joinpath(fichtempo,"atelier_"*suffixeperso)
    println("atelier $atelier")
    if ispath(atelier) ==0
        mkdir(atelier)
        println("atelier cree $atelier")
    end
    println("putzen ",joinpath("public","utilisateurs"))
    putzen(joinpath("public","utilisateurs")) #/home/ribo_tcp/app/
    return atelier
end

function renvoieepoch()
    dte=datetime2epoch(x::DateTime) = (Dates.value(x) - Dates.UNIXEPOCH)
    return dte(now())
end

function putzen(classeur::String)
    monclasseur::Vector{String}=readdir(classeur,join=true)
    println("putzen de $monclasseur")
    timestamp::Int64=renvoieepoch()
    #println(timestamp)
    for u in monclasseur
        if occursin("task",u)
            #println(split(u,'_')[2])
            if timestamp - parse(Int64,split(u,'_')[2]) >3600000
                rm(u, recursive=true)
                println("enlevé $u")
            end
        end
    end
end

function server()
    #gallica::Dict{String, Dict{String, String}} = bnf()
    gallica::Dict{String,Dict{String,Dict{String,String}}}=bnf()
    #server = listen(8080)
    server = listen(IPv4("0.0.0.0"), 8080) #<============ très important définir en IPv4 !!!! 
    println("à l'écoute ",pwd())
    while true
        conn = accept(server)
        write(conn, "ENTREE\n")
        @async begin
            try
                while true
                    # Attempt to read a line from the client
                    line = readline(conn)
                    #println("coté serveur: $line")
                    leclasseurperso::String=""
                    # Check if the line is empty or the connection is closing
                    if isempty(line)
                        #println("Client sent an empty line or connection is closing.")
                        break
                    end

                    # Split the input and validate
                    item = split(line, ";")
                    if length(item) != 5
                        println("Invalid input received: $line")
                        write(conn, "ERROR: Invalid input format\n")
                        continue
                    else
                        fonctionchoisie::String=String(item[1]) #fixé par le site
                        listefamilles::Vector{String}=[String(i) for i in split(item[2],',')] #non fixé formellement par le site donc on fait des contrôles
                        estvalidequery::Bool=true
                        for ii in listefamilles
                            if haskey(gallica, ii) === false
                                estvalidequery=false
                                error_msg = "familly $ii not found"
                                println(error_msg)
                                write(conn, "ERROR: $error_msg\n")
                            else
                                #println("valide")
                            end
                        end        
                        lescibles::Vector{String}=[String(i) for i in split(item[3],',')] #non fixé aucun contrôle possible 
                        lesqualités::Vector{String}=[String(i) for i in split(item[4],',')] #fixé par le site
                        
                        leclasseurperso=uniqueutilisateurserveur(String(item[5])) #fixé par le site
                        
                        #println(leclasseurperso,"  ",item)
                        
                        # Process the query
                        #println("Query from client: ",typeof(fonctionchoisie),"   ", listefamilles, "   ", lescibles,"   ",lesqualités,"   ",leclasseurperso)
                        if fonctionchoisie == "F1" #unique pour lancer par une boucle et récupérer ligne à ligne
                            result = extraitunefamille(gallica,listefamilles,lescibles,lesqualités,leclasseurperso,true)
                            write(conn, "$leclasseurperso;$result\n")
                        elseif fonctionchoisie  == "CNT" #idem F1 mais comptage
                            result = extraitunefamille(gallica,listefamilles,lescibles,lesqualités,leclasseurperso,false)
                            write(conn, "$leclasseurperso;$result\n")
                        elseif fonctionchoisie == "FM" # en bloc, résultats à la fin (pour le labo)
                            result = extraitparbatchfamilles(gallica,listefamilles,lescibles,lesqualités,leclasseurperso)
                            write(conn, "$leclasseurperso;$result\n")
                        else
                            error_msg = "function $fonctionchoisie is not valid"
                                println(error_msg)
                                write(conn, "ERROR: $error_msg\n")
                        end
                    # else
                    #     error_msg = "Key not found"
                    #     println(error_msg)
                    #     write(conn, "ERROR: $error_msg\n")
                    end
                end
            catch e
                println("Connection ended with error: ", e)
                write(conn, "ERROR II: $e\n")
            finally
                close(conn)  # Ensure the connection is closed
                #println("Connection closed.")
            
            end
        end
    end
end

function main()

    server()


end

main()
