import os
import subprocess
from flask import Blueprint, request, jsonify, render_template
from CTFd.models import db
from CTFd.utils.decorators import admins_only
from CTFd.plugins import register_plugin_assets_directory

class TerraformOutput(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    instance_ip = db.Column(db.String(255))
    instance_id = db.Column(db.String(255))

def load(app):
    # Initialize Database
    db.create_all()
    
    tf_bp = Blueprint("tf_validator", __name__, template_folder="templates")

    @tf_bp.route("/admin/tf-validate", methods=["GET"])
    @admins_only
    def validation_page():
        return render_template("validation.html")

    @tf_bp.route("/api/v1/terraform/output", methods=["POST"])
    @admins_only
    def receive_tf_output():
        """
        API Endpoint for CI/CD to POST terraform output json
        Example: curl -X POST -d @output.json -H "Content-Type: application/json" ...
        """
        data = request.json
        # Extract values based on typical Terraform JSON structure
        ip = data.get("instance_ip", {}).get("value")
        inst_id = data.get("instance_id", {}).get("value")

        if not ip:
            return jsonify({"success": False, "message": "No IP found in output"}), 400

        # Update or create record
        record = TerraformOutput.query.first() or TerraformOutput()
        record.instance_ip = ip
        record.instance_id = inst_id
        db.session.add(record)
        db.session.commit()

        return jsonify({"success": True, "message": f"Stored IP: {ip}"})

    @tf_bp.route("/api/v1/terraform/ping", methods=["POST"])
    @admins_only
    def validate_connectivity():
        """
        Attempts to ping the stored EC2 instance
        """
        record = TerraformOutput.query.first()
        if not record or not record.instance_ip:
            ip = "127.0.0.1"
        else:
            ip = record.instance_ip
        try:
            # -c 1 (1 packet), -W 2 (2 second timeout)
            # Note: The CTFd container must have 'iputils-ping' installed
            output = subprocess.run(
                ["ping", "-c", "1", "-W", "2", ip],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
            
            if output.returncode == 0:
                return jsonify({"success": True, "message": f"Success! {ip} is reachable."})
            else:
                return jsonify({"success": False, "message": f"Failed! {ip} is unreachable."})
        except Exception as e:
            return jsonify({"success": False, "message": str(e)})

    app.register_blueprint(tf_bp)
    register_plugin_assets_directory(app, base_path="/plugins/tf_validator/assets/")