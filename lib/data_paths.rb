module Eventer
  class DataPaths
    attr_reader :data_dir

    def initialize(data_dir)
      @data_dir = data_dir
    end

    def projects_index_file
      File.join(data_dir, '__projects__.json')
    end

    def projects_root
      File.join(data_dir, '__projects__')
    end

    def project_dir(project_id)
      File.join(projects_root, project_id)
    end

    def project_eventer_file(project_id)
      File.join(project_dir(project_id), '__eventer__.json')
    end

    def events_file(project_id)
      File.join(project_dir(project_id), '__events__.json')
    end

    def brins_file(project_id)
      File.join(project_dir(project_id), '__brins__.json')
    end

    def persos_file(project_id)
      File.join(project_dir(project_id), '__persos__.json')
    end

    def child_eventer_file(project_id, child_parts)
      File.join(project_dir(project_id), *child_parts, '__eventer__.json')
    end
  end
end
